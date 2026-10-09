#!/usr/bin/env bash
# Check small duplicated packaging facts without requiring rpm or MacPorts.
set -euo pipefail
[[ $# -le 1 ]] || { echo 'Usage: check-package-metadata.sh [source-root]' >&2; exit 2; }
root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
spec="$root/rpm/grads.spec"
port="$root/macports/grads-camo/Portfile.in"
upstream=$(awk '$1=="%global" && $2=="upstream_version" {print $3}' "$spec")
camo=$(awk '$1=="%global" && $2=="camo_version" {print $3}' "$spec")
[[ -n "$upstream" && -n "$camo" ]] || { echo 'Missing central version settings' >&2; exit 1; }
same() {
  [[ "$2" == "$3" ]] || {
    printf 'Packaging mismatch: %s (expected %s, found %s)\n' "$1" "$2" "$3" >&2
    exit 1
  }
}
same 'Debian upstream version' "$upstream" "$(sed -n 's/^UPSTREAM_VERSION=//p' "$root/debian/build-ubuntu.sh")"
same 'Debian package version' "$camo" "$(sed -n 's/^CAMO_VERSION=//p' "$root/debian/build-ubuntu.sh")"
same 'Debian 13 upstream version' "$upstream" "$(sed -n 's/^UPSTREAM_VERSION=//p' "$root/debian/build-debian.sh")"
same 'Debian 13 package version' "$camo" "$(sed -n 's/^CAMO_VERSION=//p' "$root/debian/build-debian.sh")"
same 'Debian runtime version' "$camo" "$(sed -n '/CAMO_VERSION/s/.*\(camo[0-9][0-9.]*\).*/\1/p' "$root/debian/package/rules")"
same 'MacPorts upstream version' "$upstream" "$(awk '$1=="version" {print $2}' "$port")"
same 'MacPorts runtime version' "$camo" "$(sed -n '/CAMO_VERSION/s/.*\(camo[0-9][0-9.]*\).*/\1/p' "$port")"
rpm_series=$(sed -n 's/^Patch[0-9]*: *//p' "$spec")
debian_series=$(sed '/^#/d; /^[[:space:]]*$/d' "$root/debian/package/patches/series")
macports_series=$(sed -n '/^patchfiles /,/^$/p' "$port" | sed 's/^patchfiles *//; s/\\//g' | awk 'NF {print $1}')
# Keep the documented packaging differences: Debian's HDF4 alternate library
# and MacPorts' prefix substitution in place of the Linux FHS path patch.
same 'Debian HDF4 alternate patch count' 1 "$(printf '%s\n' "$debian_series" | awk '$0=="hdf4-alt.patch" {n++} END {print n+0}')"
same 'Debian patch order' "$rpm_series" "$(printf '%s\n' "$debian_series" | sed '/^hdf4-alt\.patch$/d')"
same 'MacPorts patch order' "$(printf '%s\n' "$rpm_series" | sed '/^grads-2\.2\.1-fhs-paths\.patch$/d')" "$macports_series"
for series in "$rpm_series" "$debian_series" "$macports_series"; do
  [[ -n "$series" ]] || { echo 'Empty patch series' >&2; exit 1; }
  duplicates=$(printf '%s\n' "$series" | sort | uniq -d)
  [[ -z "$duplicates" ]] || { echo "Duplicate patches: $duplicates" >&2; exit 1; }
  while IFS= read -r patch_name; do
    [[ -f "$root/SOURCES/$patch_name" || -f "$root/debian/package/patches/$patch_name" ]] || {
      echo "Missing patch: $patch_name" >&2; exit 1;
    }
  done <<< "$series"
done
echo 'PASS: package versions and patch lists agree (documented OS differences retained)'
