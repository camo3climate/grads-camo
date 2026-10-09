#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
bash "$root/tools/check-package-metadata.sh"
mkdir -p "$root/work"
stage=$(mktemp -d "$root/work/series.XXXXXX")
for flavor in rpm debian macports; do
  bash "$root/tools/prepare-source.sh" "$flavor" "$stage/$flavor" > "$stage/$flavor.log"
  # Reconstructed source, not just a matching patch filename, must include
  # dispatch and implementation of the numerical addition on every platform.
  grep -q 'cmpwrd("percentile",name).*ffpctl' "$stage/$flavor/grads-2.2.3/src/gafunc.c"
  grep -q '^gaint ffpctl .*{' "$stage/$flavor/grads-2.2.3/src/gafunc.c"
  for name in geotrack.gs sigplot.gs; do
    cmp "$root/scripts/$name" "$stage/$flavor/grads-2.2.3/data/$name"
  done
  "${CC:-cc}" -std=c99 -Wall -Wextra -Werror \
    -I"$stage/$flavor/grads-2.2.3/src" "$root/tests/geo/geometry.c" -lm -o "$stage/test-$flavor"
  "$stage/test-$flavor"
done
for flavor in debian macports; do
  # Platform differences are confined to build configuration and the data
  # directory default in gxsubs.c. Compare every other source file, including
  # all numerical functions, not only the geographic implementation.
  diff -ru -x gxsubs.c -x '*.orig' "$stage/rpm/grads-2.2.3/src" "$stage/$flavor/grads-2.2.3/src"
  sed 's|"/usr/local/lib/grads"|"/usr/share/grads"|g' \
    "$stage/rpm/grads-2.2.3/src/gxsubs.c" > "$stage/gxsubs-rpm.c"
  sed 's|"/usr/local/lib/grads"|"/usr/share/grads"|g' \
    "$stage/$flavor/grads-2.2.3/src/gxsubs.c" > "$stage/gxsubs-$flavor.c"
  cmp "$stage/gxsubs-rpm.c" "$stage/gxsubs-$flavor.c"
done
echo "PASS: all source series, percentile presence, shared source identity, helpers and geometry; evidence in $stage"
