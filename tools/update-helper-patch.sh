#!/usr/bin/env bash
# Mechanical generation: keep installed helpers identical to scripts/.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
{
  for name in geotrack.gs sigplot.gs; do
    diff -u --label /dev/null --label "b/data/$name" /dev/null "$root/scripts/$name" || test "$?" = 1
  done
} > "$root/SOURCES/grads-2.2.3-annotation-scripts.patch"
