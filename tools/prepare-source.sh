#!/usr/bin/env bash
# Fresh source reconstruction. Refuse to reuse an existing directory.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
[[ $# -le 2 ]] || { echo 'Usage: prepare-source.sh [rpm|debian|macports] [new-directory]' >&2; exit 2; }
flavor=${1:-rpm}
target=${2:-"$root/work/$flavor"}
[[ ! -e "$target" && ! -L "$target" ]] || { echo "Refusing existing target: $target" >&2; exit 1; }
case "$flavor" in rpm|debian|macports) ;; *) echo 'Expected rpm, debian or macports' >&2; exit 2;; esac
case "$flavor" in
 rpm) series=$(sed -n 's/^Patch[0-9]*: *//p' "$root/rpm/grads.spec");;
 debian) series=$(sed '/^#/d; /^$/d' "$root/debian/package/patches/series");;
 macports) series=$(sed -n '/^patchfiles /,/^$/p' "$root/macports/grads-camo/Portfile.in" | sed 's/^patchfiles *//; s/\\//g');;
esac
[[ -n "$series" ]] || { echo "Empty patch series for $flavor" >&2; exit 1; }
# Validate inputs before creating the fresh tree. This reproduces patch order;
# platform configure flags and library-name substitutions remain in packaging.
for name in $series; do
  if [[ ! -r "$root/SOURCES/$name" && ! -r "$root/debian/package/patches/$name" ]]; then
    echo "Missing patch in $flavor series: $name" >&2
    exit 1
  fi
done
mkdir -p "$target"
tar -xzf "$root/SOURCES/grads-2.2.3-src.tar.gz" -C "$target"
tree="$target/grads-2.2.3"
for name in $series; do
  input="$root/SOURCES/$name"
  [[ -f "$input" ]] || input="$root/debian/package/patches/$name"
  patch --batch --fuzz=0 -p1 -d "$tree" -i "$input"
done
echo "Prepared: $tree"
