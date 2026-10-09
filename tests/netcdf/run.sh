#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
root=$(cd "$(dirname "$0")/../.." && pwd)
[[ $# -ge 1 && $# -le 2 ]] || {
  echo 'Usage: run.sh /path/to/grads [/path/to/patched-grads-source]' >&2; exit 2;
}
grads=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
[[ -x "$grads" ]] || { echo "Not executable: $grads" >&2; exit 2; }
source_tree=${2:-}
if [[ -n "$source_tree" ]]; then source_tree=$(cd "$source_tree" && pwd); fi
nc_config=${NC_CONFIG:-nc-config}
cc=${CC:-cc}
command -v "$nc_config" >/dev/null
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/netcdf-test.XXXXXX")
echo "NetCDF test evidence: $out"
trap 'echo "FAIL: NetCDF tests; inspect $out" >&2' ERR
# Compiler flags from nc-config intentionally undergo shell word splitting.
# shellcheck disable=SC2046
"$cc" -std=c99 -Wall -Wextra -Werror $("$nc_config" --cflags) \
  "$root/tests/netcdf/make-fixtures.c" $("$nc_config" --libs) -o "$out/make-fixtures"
cp "$root/tests/netcdf/check.gs" "$root/tests/netcdf/bad-array.ctl" "$root/tests/netcdf/noleap.ctl" "$out/"
if [[ -z ${GADDIR:-} && -r "$(dirname "$grads")/../share/grads/udpt" ]]; then
  export GADDIR="$(cd "$(dirname "$grads")/../share/grads" && pwd)"
fi
cd "$out"
./make-fixtures
if [[ -n "$source_tree" ]]; then
  awk '/^gaint read_ncatts [(]/{keep=1} keep{print} keep && /^}/{exit}' \
    "$source_tree/src/gasdf.c" >read_ncatts.inc
  awk '/^gaint ncpattrs[(]/{keep=1} keep{print} keep && /^}/{exit}' \
    "$source_tree/src/gaio.c" >ncpattrs.inc
  awk '/^static int camo_nc_scalar[(]/{keep=1} keep{print} keep && /^}/{exit}' \
    "$source_tree/src/gaio.c" >camo_nc_scalar.inc
  # This isolated native-C test instruments the actual patched function bodies,
  # while avoiding a second full build and unrelated legacy sanitizer findings.
  # shellcheck disable=SC2046
  "$cc" -std=c99 -g -O1 -Wall -Wextra -Werror \
    -fsanitize=address,undefined -fno-omit-frame-pointer -DUSENETCDF=1 \
    -I"$out" -I"$source_tree/src" -I"$("$nc_config" --includedir)/udunits2" $("$nc_config" --cflags) \
    "$root/tests/netcdf/attribute-harness.c" $("$nc_config" --libs) -o attribute-harness
  ASAN_OPTIONS=detect_leaks=0 UBSAN_OPTIONS=halt_on_error=1 \
    ./attribute-harness >attribute-harness.log 2>&1
  grep -q 'PASS: actual NetCDF attribute functions' attribute-harness.log
fi
"$grads" -blc 'run check.gs' </dev/null >run.log 2>&1
grep -q 'PASS: NetCDF metadata regression' run.log
if grep -Eq 'FAIL:|AddressSanitizer|runtime error:' run.log; then cat run.log >&2; exit 1; fi
grep -q 'NetCDF string title intact' run.log
grep -q 'Readable string variable description' run.log
grep -q 'global UInt64 uint64 0,9223372036854775808,18446744073709551615' run.log
grep -q 'global Int32 ints -2147483647,0,2147483647' run.log
grep -q 'must be scalar for GrADS' run.log
grep -q 'must be a text attribute' run.log
grep -q 'must be a numeric attribute' run.log
grep -q 'attribute name.*too long' run.log
grep -q 'must be one string' run.log
grep -q 'does not match the inferred regular GrADS time axis' run.log
grep -q 'expver (size 1) is not assigned to X/Y/Z/T/E' run.log
grep -q "SDF calendar error: 'all_leap'" run.log
grep -q "SDF calendar error: 'julian'" run.log
grep -q "SDF calendar error: 'unknown_calendar'" run.log
grep -q 'sdfctl INPUT.nc' run.log
grep -q '01MAR2024' run.log
grep -q '01JAN2026' run.log
awk -F, 'NR==1{next} NF!=3 || $3!=NR-1{exit 1} END{if(NR!=7)exit 1}' sample.csv
awk -F, '
  NR==1{next}
  NR==6{if($3!="undef")exit 1;missing++;next}
  NF!=3 || $3!=NR-1{exit 1}
  END{if(NR!=7 || missing!=1)exit 1}
' packed.csv
echo "PASS: NetCDF metadata, data and failure regression; evidence in $out"
