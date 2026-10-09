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
RPM_RELEASE="$(spec_global camo_release)"
RPM_RELEASE=${RPM_RELEASE//\%\{camo_version\}/${CAMO_VERSION}}
if [[ -z "${UPSTREAM_VERSION}" || -z "${CAMO_VERSION}" || -z "${RPM_RELEASE}" || "${RPM_RELEASE}" == *'%'* ]]; then
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

command -v rpm >/dev/null 2>&1 || { echo 'error: rpm is required to verify package metadata' >&2; exit 1; }
bash "${ROOT_DIR}/tools/check-package-metadata.sh"
bash "${ROOT_DIR}/verify-buildkit.sh"
[[ -d "${TOPDIR}/RPMS" && -d "${TOPDIR}/SRPMS" ]] || {
  echo 'error: missing RPM build directories; build and validate the packages first' >&2; exit 1;
}
BINARY_RPMS=()
SOURCE_RPMS=()
while IFS= read -r -d '' package; do BINARY_RPMS+=("$package"); done < <(
  find "${TOPDIR}/RPMS" -type f -name "grads-${UPSTREAM_VERSION}-*.rpm" -print0)
while IFS= read -r -d '' package; do SOURCE_RPMS+=("$package"); done < <(
  find "${TOPDIR}/SRPMS" -type f -name "grads-${UPSTREAM_VERSION}-*.src.rpm" -print0)
if [[ ${#BINARY_RPMS[@]} -eq 0 || ${#SOURCE_RPMS[@]} -eq 0 ]]; then
  echo "error: binary RPM or source RPM missing; run an EL8, EL9, or EL10 build helper first" >&2
  exit 1
fi

check_package() {
  local package=$1 metadata name version release
  metadata=$(rpm -qp --qf '%{NAME}\t%{VERSION}\t%{RELEASE}\n' "$package") || {
    echo "error: cannot read RPM metadata: $package" >&2; exit 1;
  }
  IFS=$'\t' read -r name version release <<< "$metadata"
  if [[ "$name" != grads || "$version" != "$UPSTREAM_VERSION" ||
        ( "$release" != "$RPM_RELEASE" && "$release" != "$RPM_RELEASE".* ) ]]; then
    echo "error: RPM version mismatch: $package ($metadata); expected grads $UPSTREAM_VERSION $RPM_RELEASE[.dist]" >&2
    exit 1
  fi
}
for package in "${BINARY_RPMS[@]}" "${SOURCE_RPMS[@]}"; do check_package "$package"; done

# Complete the inputs and checks in a temporary staging directory before making
# the versioned output visible. Existing published/staged releases stay intact.
STAGE="$(mktemp -d)"
trap 'rm -rf "${STAGE}"' EXIT
ASSET_STAGE="${STAGE}/assets"
mkdir -p "${ASSET_STAGE}"
for package in "${BINARY_RPMS[@]}" "${SOURCE_RPMS[@]}"; do
  [[ ! -e "${ASSET_STAGE}/${package##*/}" ]] || { echo "error: duplicate RPM filename: $package" >&2; exit 1; }
  cp -p "$package" "${ASSET_STAGE}/"
done
cp -p "${ROOT_DIR}/RELEASE_NOTES_TEMPLATE.md" "${ASSET_STAGE}/RELEASE_NOTES.md"

KIT_ROOT="${STAGE}/${PUBLIC_RELEASE_NAME}"
bash "${ROOT_DIR}/tools/export-public-source.sh" "$KIT_ROOT"

COPYFILE_DISABLE=1 tar -C "${STAGE}" -czf \
  "${ASSET_STAGE}/${BUILDKIT_NAME}" "${PUBLIC_RELEASE_NAME}"

(
  cd "${ASSET_STAGE}"
  if command -v sha256sum >/dev/null 2>&1; then
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | \
      xargs -0 sha256sum | sed 's|  \./|  |' > SHA256SUMS
  else
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | \
      xargs -0 shasum -a 256 | sed 's|  \./|  |' > SHA256SUMS
  fi
)

mkdir -p "${ROOT_DIR}/release"
[[ ! -e "${RELEASE_DIR}" ]] || { echo "error: output appeared during staging: ${RELEASE_DIR}" >&2; exit 1; }
mv "${ASSET_STAGE}" "${RELEASE_DIR}"
echo "==> Release assets"
find "${RELEASE_DIR}" -maxdepth 1 -type f -print | sort
