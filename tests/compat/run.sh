#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
root=$(cd "$(dirname "$0")/../.." && pwd)
[[ $# -ge 1 && $# -le 2 ]] || {
  echo 'Usage: run.sh /path/to/grads [existing-GFS-wind.nc]' >&2; exit 2;
}
grads=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
[[ -x "$grads" ]] || { echo "GrADS not executable: $grads" >&2; exit 2; }
sample=${2:-}
if [[ -n "$sample" ]]; then
  [[ -r "$sample" ]] || { echo "NetCDF fixture not readable: $sample" >&2; exit 2; }
  sample=$(cd "$(dirname "$sample")" && pwd)/$(basename "$sample")
fi
fc=${FC:-gfortran}
pkg_config=${PKG_CONFIG:-pkg-config}
command -v "$fc" >/dev/null
command -v "$pkg_config" >/dev/null
"$pkg_config" --exists libpng
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/compat-test.XXXXXX")
echo "Compatibility test evidence: $out"
trap 'echo "FAIL: compatibility smoke; inspect $out" >&2' ERR
"$fc" "$root/tests/geo/make-data.f90" -o "$out/make-data"
# pkg-config flags intentionally undergo word splitting, as in compiler builds.
# shellcheck disable=SC2046
"${CC:-cc}" -std=c99 -Wall -Wextra -Werror \
  $("$pkg_config" --cflags libpng) "$root/tests/compat/check-alpha.c" \
  $("$pkg_config" --libs libpng) -o "$out/check-alpha"
cp "$root/tests/geo/field.ctl" "$root/tests/compat/check.gs" "$out/"
if [[ -z ${GADDIR:-} && -r "$(dirname "$grads")/../share/grads/udpt" ]]; then
  export GADDIR="$(cd "$(dirname "$grads")/../share/grads" && pwd)"
fi
cd "$out"
./make-data
"$grads" -blc 'run check.gs' </dev/null >run.log 2>&1
check_log() {
  if grep -Eiq 'FAIL:|syntax error|error (in|from)|invalid operand|unable to load|txtwrite error' "$1"; then
    cat "$1" >&2; return 1
  fi
  grep -q "$2" "$1"
}
check_log run.log 'PASS: compatibility commands'
awk '
  NR==1 {if ($0!="lon value") exit 1; next}
  NF!=2 || $1!=-170+(NR-2)*10 {exit 1}
  NR==4 {if ($2!="undef") exit 1; missing++; next}
  $2!~/^-?[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$/ {exit 1}
  END {if (NR!=5 || missing!=1) exit 1}
' row.txt
awk -F, '
  NR==1 {if ($0!="lon,lat,value") exit 1; next}
  NF!=3 || $1!=-170+((NR-2)%4)*10 || $2!=-80+int((NR-2)/4)*10 {exit 1}
  NR==4 {if ($3!="NA") exit 1; missing++; next}
  $3!~/^-?[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$/ {exit 1}
  END {if (NR!=9 || missing!=1) exit 1}
' GridCase.csv
for method in bl bs ba ma; do
  awk -F, '
    NR==1 {if ($0!="lon,lat,value") exit 1; next}
    NF!=3 || $1!=-150+((NR-2)%3)*20 || $2!=-60+int((NR-2)/3)*20 {exit 1}
    $3!~/^[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$/ || $3<6.999999 || $3>7.000001 {exit 1}
    END {if (NR!=10) exit 1}
  ' "re-$method.csv"
done
for file in theme-classic.png theme-modern.png alpha-overlap.png; do test -s "$file"; done
./check-alpha alpha-overlap.png
if [[ -n "$sample" ]]; then
  "$grads" -blc "run $root/tests/compat/netcdf.gs $sample" </dev/null >netcdf.log 2>&1
  check_log netcdf.log 'PASS: existing GFS NetCDF fixture'
  test -s netcdf-wind.png
  awk -F, '
    NR==1 {if ($0!="lon,lat,value") exit 1; next}
    NF!=3 || $3!~/^[0-9]+([.][0-9]+)?([eE][-+]?[0-9]+)?$/ || $3>200 {exit 1}
    END {if (NR!=10) exit 1}
  ' netcdf-wind.csv
fi
echo "PASS: compatibility smoke (not a full regridding or data-format validation); evidence in $out"
