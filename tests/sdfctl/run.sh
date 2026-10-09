#!/usr/bin/env bash
# NetCDF-C fixtures and GrADS checks; originals and installed software untouched.
set -euo pipefail
export LC_ALL=C
[[ $# == 1 ]] || { echo 'Usage: run.sh /path/to/grads' >&2; exit 2; }
root=$(cd "$(dirname "$0")/../.." && pwd)
grads=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
[[ -x "$grads" ]] || { echo "GrADS not executable: $grads" >&2; exit 2; }
nc_config=${NC_CONFIG:-nc-config}
command -v "$nc_config" >/dev/null || { echo 'NetCDF-C nc-config is required for fixtures' >&2; exit 2; }
if command -v sha256sum >/dev/null 2>&1; then sha=(sha256sum); else sha=(shasum -a 256); fi
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/sdfctl-test.XXXXXX")
echo "sdfctl evidence: $out"
trap 'echo "FAIL: sdfctl regression; inspect $out" >&2' ERR
# nc-config emits compiler/linker tokens intentionally split as build flags.
# shellcheck disable=SC2046
"${CC:-cc}" -std=c99 -Wall -Wextra -Werror $("$nc_config" --cflags) \
  "$root/tests/sdfctl/make-data.c" $("$nc_config" --libs) -o "$out/make-data"
cp "$root/tests/sdfctl/check.gs" "$out/"
if [[ -z ${GADDIR:-} && -r "$(dirname "$grads")/../share/grads/udpt" ]]; then
  export GADDIR="$(cd "$(dirname "$grads")/../share/grads" && pwd)"
fi
cd "$out"
./make-data
"${sha[@]}" ./*.nc > input-before.sha256
printf 'Do not overwrite this descriptor.\n' > existing.ctl
cp existing.ctl existing-reference.txt
ln -s regular.nc input-link.ctl
"$grads" -blc 'run check.gs' </dev/null > run.log 2>&1
"${sha[@]}" -c input-before.sha256 > input-after.log
cmp existing.ctl existing-reference.txt
[[ -L input-link.ctl && $(readlink input-link.ctl) == regular.nc ]]
for unwritten in PreviewCase.ctl regular.nc.ctl FloatPreview.ctl bad-args.ctl bad-answer.ctl bad-case.ctl \
  bad-curvilinear.ctl bad-irregularxy.ctl bad-calendar360.ctl bad-ambiguous.ctl \
  bad-groups.ctl bad-packedaxis.ctl bad-irregulartime.ctl bad-aliascollision.ctl \
  bad-oversizedgrid.ctl; do
  [[ ! -e "$unwritten" && ! -L "$unwritten" ]] || { echo "FAIL: unexpected output $unwritten" >&2; exit 1; }
done
for descriptor in RegularCase.ctl DescendingCase.ctl; do
  [[ -s "$descriptor" ]]
  grep -q '^XDEF i 3 LINEAR 100 10$' "$descriptor"
  grep -q '^YDEF j 3 LINEAR -10 10$' "$descriptor"
  if grep -Eq '^(TDEF|ZDEF|EDEF|UNDEF|VARS|UNPACK)' "$descriptor"; then
    echo "FAIL: supplemental descriptor duplicates original metadata: $descriptor" >&2; exit 1
  fi
done
grep -q '^OPTIONS yrev$' DescendingCase.ctl
awk '
  $1=="XDEF" {
    if ($2!="i" || $3!=100 || $4!="LINEAR" || $5!=130 ||
        $6<0.0999998 || $6>0.1000002) exit 1
    found=1
  }
  END {if (!found) exit 1}
' FloatRegular.ctl
grep -q 'grid exceeds the legacy SDF reader' run.log
grep -q 'variable aliases collide' run.log
if grep -q '^OPTIONS yrev$' RegularCase.ctl; then echo 'FAIL: ascending Y incorrectly reversed' >&2; exit 1; fi
if grep -q 'FAIL:' run.log || ! grep -q '^PASS: sdfctl regression' run.log; then
  sed -n '1,320p' run.log >&2
  exit 1
fi
grep '^PASS: sdfctl regression' run.log
echo "PASS: input hashes, preview non-writing, exclusive save and XDF-only metadata; evidence in $out"
