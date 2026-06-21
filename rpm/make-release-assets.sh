#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SPEC_FILE="${ROOT_DIR}/rpm/grads.spec"
TOPDIR="${ROOT_DIR}/.rpmbuild"

spec_global() {
  awk -v key="$1" '$1 == "%global" && $2 == key { print $3; exit }' "${SPEC_FILE}"
}

UPSTREAM_VERSION="$(spec_global upstream_version)"
CAMO_VERSION="$(spec_global camo_version)"
if [[ -z "${UPSTREAM_VERSION}" || -z "${CAMO_VERSION}" ]]; then
  echo "error: cannot read central version globals from ${SPEC_FILE}" >&2
  exit 1
fi

PUBLIC_RELEASE_NAME="grads-${UPSTREAM_VERSION}-${CAMO_VERSION}"
GITHUB_TAG="v${UPSTREAM_VERSION}-${CAMO_VERSION}"
RELEASE_DIR="${ROOT_DIR}/release/${GITHUB_TAG}"
BUILDKIT_NAME="${PUBLIC_RELEASE_NAME}-buildkit.tar.gz"

if [[ -e "${RELEASE_DIR}" ]]; then
  echo "error: release directory already exists: ${RELEASE_DIR}" >&2
  echo "Refusing to overwrite release assets; bump the CAMO version or remove an unpublished directory explicitly." >&2
  exit 1
fi

mapfile -d '' BINARY_RPMS < <(find "${TOPDIR}/RPMS" -type f \
  -name "grads-${UPSTREAM_VERSION}-*.rpm" -print0 2>/dev/null | sort -z)
mapfile -d '' SOURCE_RPMS < <(find "${TOPDIR}/SRPMS" -type f \
  -name "grads-${UPSTREAM_VERSION}-*.src.rpm" -print0 2>/dev/null | sort -z)
if [[ ${#BINARY_RPMS[@]} -eq 0 || ${#SOURCE_RPMS[@]} -eq 0 ]]; then
  echo "error: binary RPM or source RPM missing; run ./rpm/build-el8.sh first" >&2
  exit 1
fi

mkdir -p "${RELEASE_DIR}"
cp -p "${BINARY_RPMS[@]}" "${SOURCE_RPMS[@]}" "${RELEASE_DIR}/"
cp -p "${ROOT_DIR}/RELEASE_NOTES_TEMPLATE.md" "${RELEASE_DIR}/RELEASE_NOTES.md"
if [[ -f "${ROOT_DIR}/logs/rpmbuild.log" ]]; then
  cp -p "${ROOT_DIR}/logs/rpmbuild.log" "${RELEASE_DIR}/"
fi

STAGE="$(mktemp -d)"
trap 'rm -rf "${STAGE}"' EXIT
KIT_ROOT="${STAGE}/${PUBLIC_RELEASE_NAME}"
mkdir -p "${KIT_ROOT}/docs" "${KIT_ROOT}/rpm" "${KIT_ROOT}/SOURCES" "${KIT_ROOT}/LICENSES"
cp -p \
  "${ROOT_DIR}/README.md" \
  "${ROOT_DIR}/CHANGELOG.md" \
  "${ROOT_DIR}/NOTICE.md" \
  "${ROOT_DIR}/LICENSE" \
  "${ROOT_DIR}/RELEASE_NOTES_TEMPLATE.md" \
  "${ROOT_DIR}/SHA256SUMS" \
  "${KIT_ROOT}/"
cp -p "${ROOT_DIR}/.gitignore" "${KIT_ROOT}/"
cp -p "${ROOT_DIR}"/docs/*.md "${KIT_ROOT}/docs/"
cp -p "${ROOT_DIR}"/LICENSES/*.txt "${KIT_ROOT}/LICENSES/"
cp -p "${ROOT_DIR}"/rpm/* "${KIT_ROOT}/rpm/"
cp -p "${ROOT_DIR}"/SOURCES/* "${KIT_ROOT}/SOURCES/"

COPYFILE_DISABLE=1 tar -C "${STAGE}" -czf \
  "${RELEASE_DIR}/${BUILDKIT_NAME}" "${PUBLIC_RELEASE_NAME}"

(
  cd "${RELEASE_DIR}"
  if command -v sha256sum >/dev/null 2>&1; then
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | \
      xargs -0 sha256sum | sed 's|  \./|  |' > SHA256SUMS
  else
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | \
      xargs -0 shasum -a 256 | sed 's|  \./|  |' > SHA256SUMS
  fi
)

echo "==> Release assets"
find "${RELEASE_DIR}" -maxdepth 1 -type f -print | sort
