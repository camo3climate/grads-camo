#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
id_file="${root_dir}/BUILDKIT-ID.txt"
require_buildkit=0
status=0

if [[ "${1:-}" == "--require-buildkit" ]]; then
  require_buildkit=1
elif [[ $# -gt 0 ]]; then
  echo "usage: $0 [--require-buildkit]" >&2
  exit 2
fi

if [[ ! -f "${id_file}" ]]; then
  echo "error: BUILDKIT-ID.txt not found" >&2
  exit 1
fi

read_expected() {
  local key=$1
  awk -F': ' -v key="${key}" '$1 == key { print $2 }' "${id_file}"
}

check_sha() {
  local label=$1
  local expected=$2
  local file=$3

  if [[ ! -f "${file}" ]]; then
    echo "MISSING  ${label}: ${file}"
    status=1
    return
  fi

  local actual
  actual="$(sha256sum "${file}" | awk '{print $1}')"
  if [[ "${actual}" == "${expected}" ]]; then
    echo "OK       ${label}: ${actual}  ${file#${root_dir}/}"
  else
    echo "MISMATCH ${label}: expected ${expected}"
    echo "         ${label}: actual   ${actual}  ${file#${root_dir}/}"
    status=1
  fi
}

check_expected_sha() {
  local label=$1
  local key=$2
  local file=$3
  local expected

  expected="$(read_expected "${key}")"
  if [[ -n "${expected}" ]]; then
    check_sha "${label}" "${expected}" "${file}"
  else
    echo "SKIP     ${label}: ${key} not recorded in BUILDKIT-ID.txt"
  fi
}

upstream_version="$(awk '/^%global upstream_version / { print $3 }' "${root_dir}/rpm/grads.spec")"
camo_version="$(awk '/^%global camo_version / { print $3 }' "${root_dir}/rpm/grads.spec")"
buildkit_name="grads-${upstream_version}-${camo_version}-buildkit.tar.gz"
buildkit_path="${root_dir}/outputs/${buildkit_name}"

buildkit_expected="$(read_expected "buildkit-sha256")"
geo_expected="$(read_expected "geo-commands-patch-sha256")"

if [[ -n "${buildkit_expected}" ]]; then
  if [[ -f "${buildkit_path}" ]]; then
    check_sha "buildkit" "${buildkit_expected}" "${buildkit_path}"
  elif [[ "${require_buildkit}" -eq 1 ]]; then
    echo "MISSING  buildkit: ${buildkit_path}"
    status=1
  else
    echo "SKIP     buildkit: ${buildkit_path} not present locally"
  fi
fi

check_expected_sha "themes rgbmap patch" "themes-rgbmap-patch-sha256" "${root_dir}/SOURCES/grads-2.2.1-themes-rgbmap.patch"
check_expected_sha "camo config patch" "camo-config-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-camo-config.patch"
check_sha "geo patch" "${geo_expected}" "${root_dir}/SOURCES/grads-2.2.3-geo-commands.patch"
check_expected_sha "udunits patch" "udunits2-include-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-udunits2-include.patch"
check_expected_sha "hdf5 serial patch" "hdf5-serial-ldflags-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-hdf5-serial-ldflags.patch"
check_expected_sha "hdf5 patch" "hdf5-modern-api-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-hdf5-modern-api.patch"
check_expected_sha "grib2 patch" "grib2-g2c-portable-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-enable-grib2-g2c-portable.patch"
check_expected_sha "txtwrite patch" "txtwrite-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-txtwrite.patch"
check_expected_sha "modern gxout2 patch" "modern-gxout2-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-modern-gxout2.patch"
check_expected_sha "re limited patch" "re-limited-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-re-limited.patch"
check_expected_sha "axis label size patch" "axis-label-size-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-axis-label-size.patch"
check_expected_sha "modern startup defaults patch" "modern-startup-defaults-patch-sha256" "${root_dir}/SOURCES/grads-2.2.3-modern-startup-defaults.patch"

if [[ "${status}" -ne 0 ]]; then
  echo "Buildkit verification failed."
  exit "${status}"
fi

echo "Buildkit verification passed."
