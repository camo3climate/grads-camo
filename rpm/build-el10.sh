#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SPEC_FILE="${ROOT_DIR}/rpm/grads.spec"
TOPDIR="${ROOT_DIR}/.rpmbuild"
LOG_DIR="${ROOT_DIR}/logs"
LOG_FILE="${LOG_DIR}/rpmbuild-el10.log"

if [[ ${EUID} -eq 0 ]]; then
  echo "error: run rpmbuild as an ordinary user, not root" >&2
  exit 1
fi
if ! command -v rpmbuild >/dev/null 2>&1; then
  echo "error: rpmbuild is not installed; see docs/BUILD-EL10.md" >&2
  exit 1
fi
if command -v sha256sum >/dev/null 2>&1; then
  echo "==> Verifying source and patch checksums"
  (cd "${ROOT_DIR}" && sha256sum --quiet -c SHA256SUMS)
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}:${VERSION_ID:-}" in
    almalinux:10*|rocky:10*|rhel:10*|centos:10*) ;;
    *) echo "warning: intended for EL10; detected ${PRETTY_NAME:-unknown}" >&2 ;;
  esac
fi

show_config_log_on_error() {
  local config_log
  config_log="$(find "${TOPDIR}/BUILD" -path '*/config.log' -type f 2>/dev/null | head -n 1 || true)"
  if [[ -n "${config_log}" ]]; then
    echo "Build failed; inspect ${config_log} and ${LOG_FILE}" >&2
  fi
}
trap show_config_log_on_error ERR

rm -rf "${TOPDIR}"
mkdir -p "${TOPDIR}"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} "${LOG_DIR}"
cp -a "${ROOT_DIR}/SOURCES/." "${TOPDIR}/SOURCES/"
cp -p "${SPEC_FILE}" "${TOPDIR}/SPECS/grads.spec"

if command -v sha256sum >/dev/null 2>&1; then
  echo "==> RPM input patch identity"
  sed -n '1,16p' "${ROOT_DIR}/BUILDKIT-ID.txt"
  sha256sum "${TOPDIR}/SOURCES/grads-2.2.3-src.tar.gz"
  sha256sum "${TOPDIR}/SOURCES/grads-2.2.1-themes-rgbmap.patch"
  sha256sum "${TOPDIR}/SOURCES/grads-2.2.3-udunits2-include.patch"
  sha256sum "${TOPDIR}/SOURCES/grads-2.2.3-txtwrite.patch"
  sha256sum "${TOPDIR}/SOURCES/grads-2.2.3-geo-commands.patch"
  sed -n '1,8p' "${TOPDIR}/SOURCES/grads-2.2.1-themes-rgbmap.patch"
  sed -n '1,10p' "${TOPDIR}/SOURCES/grads-2.2.3-geo-commands.patch"
fi

DOC_STAGE="$(mktemp -d)"
trap 'rm -rf "${DOC_STAGE}"; show_config_log_on_error' ERR
trap 'rm -rf "${DOC_STAGE}"' EXIT
mkdir -p "${DOC_STAGE}/grads-camo-docs/docs" "${DOC_STAGE}/grads-camo-docs/LICENSES"
cp -p "${ROOT_DIR}/README.md" "${ROOT_DIR}/CHANGELOG.md" \
  "${ROOT_DIR}/NOTICE.md" "${DOC_STAGE}/grads-camo-docs/"
cp -p "${ROOT_DIR}"/docs/*.md "${DOC_STAGE}/grads-camo-docs/docs/"
cp -p "${ROOT_DIR}"/docs/*.html "${DOC_STAGE}/grads-camo-docs/docs/"
cp -p "${ROOT_DIR}"/LICENSES/*.txt "${DOC_STAGE}/grads-camo-docs/LICENSES/"
tar -C "${DOC_STAGE}" -czf \
  "${TOPDIR}/SOURCES/grads-camo-packaging-docs.tar.gz" grads-camo-docs

echo "==> Building source and binary RPMs for EL10"
set +e
rpmbuild -ba "${TOPDIR}/SPECS/grads.spec" \
  --define "_topdir ${TOPDIR}" 2>&1 | tee "${LOG_FILE}"
status=${PIPESTATUS[0]}
set -e
if [[ ${status} -ne 0 ]]; then
  show_config_log_on_error
  exit "${status}"
fi

echo
echo "==> Built RPMs"
find "${TOPDIR}/RPMS" "${TOPDIR}/SRPMS" -type f -name '*.rpm' -print | sort
