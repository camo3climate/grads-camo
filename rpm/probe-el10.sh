#!/usr/bin/env bash
# Collect the EL10 repository and toolchain facts needed by the shared spec.
set -u

output=${1:-grads-el10-probe-$(date +%Y%m%d-%H%M%S).txt}
packages=(
  rpm-build rpmdevtools redhat-rpm-config gcc gcc-c++ make autoconf automake libtool
  cairo-devel gd-devel fontconfig-devel freetype-devel
  libX11-devel libXext-devel libXmu-devel libXrender-devel
  netcdf-devel hdf-devel hdf5-devel udunits2-devel
  g2clib-devel g2clib-static libaec-devel
  libgeotiff-devel shapelib-devel libpng-devel jasper-devel zlib-devel
)
providers=(
  '*/libmfhdf.so' '*/hdf.h' '*/libg2c*.a' '*/grib2.h'
  '*/X11/Xmu/WinUtil.h' '*/libshp.so' '*/shapefil.h'
  '*/libsz.so.2' '*/libnetcdf.so'
)

section() { printf '\n===== %s =====\n' "$1"; }
run() {
  printf '$'; printf ' %q' "$@"; printf '\n'
  "$@" 2>&1 || printf '[exit status: %s]\n' "$?"
}

collect() {
  section 'OS AND ARCHITECTURE'
  run cat /etc/os-release
  run uname -a
  run rpm -E '%{?rhel}'
  run rpm -E '%{_arch} %{_libdir} %{_prefix}'
  section 'TOOLCHAIN AND RPM FLAGS'
  run rpm --version
  run rpmbuild --version
  run gcc --version
  run rpm -E '%{build_cflags}'
  run rpm -E '%{build_ldflags}'
  section 'ENABLED REPOSITORIES'
  run dnf repolist --enabled
  section 'PACKAGE CANDIDATES'
  local package provider
  for package in "${packages[@]}"; do
    printf '\n--- %s ---\n' "$package"
    dnf repoquery --available --latest-limit 1 \
      --qf '%{name}-%{evr}.%{arch}  repo=%{repoid}' "$package" 2>&1 || true
  done
  section 'FILE PROVIDERS'
  for provider in "${providers[@]}"; do
    printf '\n--- %s ---\n' "$provider"
    dnf repoquery --available --latest-limit 1 --whatprovides "$provider" \
      --qf '%{name}-%{evr}.%{arch}  repo=%{repoid}' 2>&1 || true
  done
}

collect >"$output"
printf 'EL10 probe written to %s\n' "$output"
