#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
root=$(cd "$(dirname "$0")/../.." && pwd)
[[ $# -ge 1 && $# -le 2 ]] || {
  echo 'Usage: run.sh /path/to/Cairo-grads [/path/to/patched-source/src]' >&2
  exit 2
}
grads=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
src=${2:-"$root/work/macos-local/grads-2.2.3/src"}
[[ -x "$grads" && -r "$src/camo_colormap_impl.inc" ]] || {
  echo 'Missing executable or reconstructed source; build camo26.2 first.' >&2
  exit 2
}
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/theme-test.XXXXXX")
echo "Theme regression evidence: $out"
trap 'echo "FAIL: theme regression; inspect $out" >&2' ERR
"${CC:-cc}" -std=c99 -Wall -Wextra -Werror -I"$src" \
  "$root/tests/theme/state.c" -o "$out/state"
"$out/state"
"${FC:-gfortran}" "$root/tests/geo/make-data.f90" -o "$out/make-data"
cp "$root/tests/geo/field.ctl" "$root/tests/theme/check.gs" "$out/"
if [[ -z ${GADDIR:-} && -r "$(dirname "$grads")/../share/grads/udpt" ]]; then
  export GADDIR="$(cd "$(dirname "$grads")/../share/grads" && pwd)"
fi
cd "$out"
./make-data
"$grads" -blc 'run check.gs' </dev/null >run.log 2>&1
if grep -Eiq 'FAIL:|syntax error|error (in|from)|invalid operand|unable to load' run.log; then
  cat run.log >&2
  exit 1
fi
grep -q 'PASS: theme lifecycle' run.log
for file in modern-startup.png paper.png paper.pdf paper.svg; do
  test -s "$file"
done
echo "PASS: theme lifecycle and paper exports; visual QA still required: $out"
