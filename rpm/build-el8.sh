#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SPEC_FILE="${ROOT_DIR}/rpm/grads.spec"
TOPDIR="${ROOT_DIR}/.rpmbuild"
LOG_DIR="${ROOT_DIR}/logs"
LOG_FILE="${LOG_DIR}/rpmbuild.log"

if [[ ${EUID} -eq 0 ]]; then
  echo "error: run rpmbuild as an ordinary user, not root" >&2
  exit 1
fi

if ! command -v rpmbuild >/dev/null 2>&1; then
  echo "error: rpmbuild is not installed; see docs/BUILD-EL8.md" >&2
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}:${VERSION_ID:-}" in
    almalinux:8*|rocky:8*|rhel:8*|centos:8*) ;;
    *) echo "warning: intended for EL8; detected ${PRETTY_NAME:-unknown}" >&2 ;;
  esac
fi

show_config_log_on_error() {
  local config_log
  config_log="$(find "${TOPDIR}/BUILD" -path '*/config.log' -type f 2>/dev/null | head -n 1 || true)"
  if [[ -n "${config_log}" ]]; then
    echo >&2
    echo "Build failed; inspect ${config_log} and ${LOG_FILE}" >&2
  fi
}
trap show_config_log_on_error ERR

rm -rf "${TOPDIR}"
mkdir -p "${TOPDIR}"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} "${LOG_DIR}"
cp -a "${ROOT_DIR}/SOURCES/." "${TOPDIR}/SOURCES/"
cp -p "${SPEC_FILE}" "${TOPDIR}/SPECS/grads.spec"

DOC_STAGE="$(mktemp -d)"
trap 'rm -rf "${DOC_STAGE}"; show_config_log_on_error' ERR
trap 'rm -rf "${DOC_STAGE}"' EXIT
mkdir -p "${DOC_STAGE}/grads-camo-docs/docs" "${DOC_STAGE}/grads-camo-docs/LICENSES"
cp -p \
  "${ROOT_DIR}/README.md" \
  "${ROOT_DIR}/CHANGELOG.md" \
  "${ROOT_DIR}/NOTICE.md" \
  "${DOC_STAGE}/grads-camo-docs/"
cp -p "${ROOT_DIR}"/docs/*.md "${DOC_STAGE}/grads-camo-docs/docs/"
cp -p "${ROOT_DIR}"/LICENSES/*.txt "${DOC_STAGE}/grads-camo-docs/LICENSES/"
tar -C "${DOC_STAGE}" -czf \
  "${TOPDIR}/SOURCES/grads-camo-packaging-docs.tar.gz" grads-camo-docs

echo "==> Building source and binary RPMs"
set +e
rpmbuild -ba "${TOPDIR}/SPECS/grads.spec" \
  --define "_topdir ${TOPDIR}" \
  --define "optflags -O2 -g -pipe -Wall" \
  --define "_build_ldflags %{nil}" \
  2>&1 | tee "${LOG_FILE}"
status=${PIPESTATUS[0]}
set -e
if [[ ${status} -ne 0 ]]; then
  show_config_log_on_error
  exit "${status}"
fi

echo
echo "==> Built RPMs"
find "${TOPDIR}/RPMS" "${TOPDIR}/SRPMS" -type f -name '*.rpm' -print | sort
