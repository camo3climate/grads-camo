#!/usr/bin/env bash
# Copy only allowlisted package documentation, never development notes.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
[[ $# == 1 && $1 == /* ]] || { echo 'Usage: copy-public-docs.sh ABS_OUTPUT' >&2; exit 2; }
out=$1
mkdir -p "$out/docs" "$out/LICENSES"
cp "$root/README.md" "$root/CHANGELOG.md" "$root/NOTICE.md" "$out/"
cp "$root"/LICENSES/*.txt "$out/LICENSES/"
while IFS= read -r path; do
  case "$path" in
    docs/*.md|docs/*.html)
      [[ $path != docs/*/* ]] || continue
      [[ -f "$root/$path" ]] || { echo "Missing public document: $path" >&2; exit 1; }
      cp "$root/$path" "$out/docs/";;
  esac
done < "$root/PUBLIC-FILES.txt"
