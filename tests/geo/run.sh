#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
grads=${1:?usage: run.sh /absolute/path/to/grads [/absolute/source/src]}
src=${2:-"$root/work/macos-local/grads-2.2.3/src"}
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/geo-test.XXXXXX")
"${CC:-cc}" -std=c99 -Wall -Wextra -Werror -I"$src" "$root/tests/geo/geometry.c" -lm -o "$out/geometry"
"$out/geometry"
"${FC:-gfortran}" "$root/tests/geo/make-data.f90" -o "$out/make-data"
cp "$root/tests/geo/field.ctl" "$root/tests/geo/check.gs" "$root/tests/geo/track.txt" "$out/"
cp "$root/scripts/geotrack.gs" "$root/scripts/sigplot.gs" "$out/"
cd "$out"
./make-data
"$grads" -blc 'run check.gs' </dev/null >run.log 2>&1
if grep -Eq 'FAIL:|Syntax Error|Error in |Invalid operand|Unable to load|error in' run.log; then
  cat run.log; exit 1
fi
grep -q 'PASS: geographic commands and helpers' run.log
grep -q 'sigplot: 2 markers; mode=sig' run.log
grep -q 'sigplot: 3 markers; mode=nonsig' run.log
grep -q 'sigplot: 0 markers; mode=sig' run.log
grep -q 'sigplot: 7 markers; mode=nonsig' run.log
for file in geographic-latlon.png geographic-nps.png geographic-sps.png geographic-robinson.png geographic-mollweide.png geographic-orthogr.png significance.png; do
  test -s "$file"
done
echo "PASS: results retained at $out"
