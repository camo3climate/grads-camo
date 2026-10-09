#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
UPSTREAM_VERSION=2.2.3
CAMO_VERSION=camo26.2

if [[ ! -r /etc/os-release ]]; then
  echo "error: /etc/os-release is required" >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ ${EUID} -eq 0 ]]; then
  echo "error: build as an ordinary user" >&2; exit 1
fi
if [[ ${ID:-}:${VERSION_ID:-} != debian:13 ]]; then
  echo "error: this helper targets Debian 13" >&2; exit 1
fi
DEB_DISTRIBUTION=trixie
if ! command -v dpkg-buildpackage >/dev/null 2>&1; then
  echo "error: install build-essential and dpkg-dev first" >&2
  exit 1
fi

BUILD_ROOT="${ROOT_DIR}/.debbuild/debian-${VERSION_ID}"
SOURCE_DIR="${BUILD_ROOT}/grads-${UPSTREAM_VERSION}"
OUTPUT_DIR="${ROOT_DIR}/outputs/debian-${VERSION_ID}"
DEB_VERSION="${UPSTREAM_VERSION}+${CAMO_VERSION}-1~debian${VERSION_ID}.1"

rm -rf "${BUILD_ROOT}"
mkdir -p "${BUILD_ROOT}" "${OUTPUT_DIR}"
tar -xzf "${ROOT_DIR}/SOURCES/grads-${UPSTREAM_VERSION}-src.tar.gz" -C "${BUILD_ROOT}"
cp -a "${ROOT_DIR}/debian/package/." "${SOURCE_DIR}/debian/"
cp -p "${ROOT_DIR}/README.md" "${ROOT_DIR}/CHANGELOG.md" "${SOURCE_DIR}/"
mkdir -p "${SOURCE_DIR}/debian/patches" "${SOURCE_DIR}/debian/vendor"

while IFS= read -r patch_name; do
  [[ -n "${patch_name}" && ${patch_name:0:1} != '#' ]] || continue
  if [[ -f "${ROOT_DIR}/SOURCES/${patch_name}" ]]; then
    cp -p "${ROOT_DIR}/SOURCES/${patch_name}" "${SOURCE_DIR}/debian/patches/"
  fi
done <"${SOURCE_DIR}/debian/patches/series"
cp -p "${ROOT_DIR}/SOURCES/cairo.m4" "${SOURCE_DIR}/debian/vendor/"
cp -p "${ROOT_DIR}/SOURCES/libshp.m4" "${SOURCE_DIR}/debian/vendor/"
cp -p "${ROOT_DIR}/SOURCES/udpt.in" "${SOURCE_DIR}/debian/vendor/"
sed "s/@DEB_VERSION@/${DEB_VERSION}/g; s/@UBUNTU_VERSION@/${VERSION_ID}/g; s/@DISTRIBUTION@/${DEB_DISTRIBUTION}/g" \
  "${SOURCE_DIR}/debian/changelog.in" | sed "s/for Ubuntu /for Debian /" >"${SOURCE_DIR}/debian/changelog"
rm "${SOURCE_DIR}/debian/changelog.in"

(cd "${SOURCE_DIR}" && dpkg-buildpackage -b -us -uc)
find "${BUILD_ROOT}" -maxdepth 1 -type f \
  \( -name '*.deb' -o -name '*.buildinfo' -o -name '*.changes' \) \
  -exec cp -p {} "${OUTPUT_DIR}/" \;
find "${OUTPUT_DIR}" -maxdepth 1 -type f -print | sort
