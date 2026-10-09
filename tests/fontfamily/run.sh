#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
grads=${1:?usage: run.sh /absolute/path/to/grads}
shift
if [[ $# == 0 ]]; then set -- Helvetica Osaka; fi
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/font-test.XXXXXX")
i=0
for family in "$@"; do
  i=$((i+1))
  mkdir "$out/$i"
  (
    cd "$out/$i"
    "$grads" -blc "run $root/tests/fontfamily/single-family.gs $family" </dev/null >run.log 2>&1
    grep -q 'PASS: single family' run.log
    ! grep -q 'FAIL:' run.log
    test -s font.png && test -s font.pdf
  )
done
echo "PASS: separate-process font output at $out (family availability not asserted)"
