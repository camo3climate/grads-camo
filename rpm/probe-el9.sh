#!/usr/bin/env bash
# Collect the EL9 facts needed before changing the GrADS RPM spec.

set -u

output=${1:-grads-el9-probe-$(date +%Y%m%d-%H%M%S).txt}

packages=(
  rpm-build rpmdevtools redhat-rpm-config gcc make autoconf automake libtool
  cairo-devel gd-devel fontconfig-devel freetype-devel
  libX11-devel libXext-devel libXmu-devel libXrender-devel
  netcdf-devel hdf-devel hdf5-devel udunits2-devel
  g2clib-devel g2clib-static libaec-devel
  libgeotiff-devel shapelib-devel libpng-devel jasper-devel zlib-devel
)

providers=(
  '*/libmfhdf.so'
  '*/hdf.h'
  '*/libg2c*.a'
  '*/grib2.h'
  '*/X11/Xmu/WinUtil.h'
  '*/libshp.so'
  '*/shapefil.h'
  '*/libsz.so.2'
  '*/libnetcdf.so'
)

section() {
  printf '\n===== %s =====\n' "$1"
}

run() {
  printf '$'
  printf ' %q' "$@"
  printf '\n'
  "$@" 2>&1 || printf '[exit status: %s]\n' "$?"
}

collect() {
  section 'OS AND ARCHITECTURE'
  run cat /etc/os-release
  run uname -a
  run rpm -E '%{?rhel}'
  run rpm -E '%{_arch} %{_libdir} %{_prefix}'

  section 'TOOLCHAIN'
  run rpm --version
  run rpmbuild --version
  run gcc --version
  run make --version
  run autoconf --version
  run automake --version

  section 'RPM FLAGS'
  run rpm -E '%{build_cflags}'
  run rpm -E '%{build_ldflags}'
  run rpm -E '%{set_build_flags}'

  section 'ENABLED REPOSITORIES'
  run dnf repolist --enabled

  if ! command -v repoquery >/dev/null 2>&1 && ! dnf repoquery --help >/dev/null 2>&1; then
    section 'REPOQUERY UNAVAILABLE'
    printf '%s\n' 'Install dnf-plugins-core, then run this probe again.'
    return
  fi

  section 'PACKAGE CANDIDATES'
  local package
  for package in "${packages[@]}"; do
    printf '\n--- %s ---\n' "$package"
    dnf repoquery --available --latest-limit 1 \
      --qf '%{name}-%{evr}.%{arch}  repo=%{repoid}' "$package" 2>&1 || true
  done

  section 'FILE PROVIDERS'
  local provider
  for provider in "${providers[@]}"; do
    printf '\n--- %s ---\n' "$provider"
    dnf repoquery --available --latest-limit 1 --whatprovides "$provider" \
      --qf '%{name}-%{evr}.%{arch}  repo=%{repoid}' 2>&1 || true
  done

  section 'G2CLIB DETAILS (EL9 IS EXPECTED TO USE A VERSIONED STATIC LIBRARY)'
  run dnf repoquery --available --requires --resolve g2clib-devel
  run dnf repoquery --available --list g2clib-devel

  section 'HDF4 DETAILS'
  run dnf repoquery --available --requires --resolve hdf-devel
  run dnf repoquery --available --list hdf-devel
}

collect >"$output"
printf 'EL9 probe written to %s\n' "$output"
