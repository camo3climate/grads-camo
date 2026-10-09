#!/usr/bin/env bash
# Export an explicit public source allowlist.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
[[ $# == 1 && $1 == /* && ! -e $1 ]] || { echo 'Usage: export-public-source.sh NEW_ABS_OUTPUT' >&2; exit 2; }
out=$1
cd "$root"
paths=()
while IFS= read -r path; do
  [[ -n $path && $path != \#* ]] || continue
  paths+=("$path")
done < PUBLIC-FILES.txt
mkdir -p "$out/SOURCES"
COPYFILE_DISABLE=1 tar -cf - "${paths[@]}" | tar -xf - -C "$out"
inputs=(grads-2.2.3-src.tar.gz cairo.m4 libshp.m4 udpt.in)
while IFS= read -r path; do inputs+=("$path"); done < <(sed -n 's/^Patch[0-9]*: *//p' rpm/grads.spec)
for path in "${inputs[@]}"; do
  cp "SOURCES/$path" "$out/SOURCES/"
  awk -v file="SOURCES/$path" '$2==file {print}' SHA256SUMS >> "$out/SHA256SUMS"
done
bash "$out/verify-buildkit.sh"
bash "$out/tools/check-package-metadata.sh"
