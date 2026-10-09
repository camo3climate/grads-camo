#!/usr/bin/env bash
# Fixture-only rpm query stub: files contain NAME<TAB>VERSION<TAB>RELEASE.
# Never place this on a real package-build or publication PATH.
set -euo pipefail
[[ $# == 4 && $1 == -qp && $2 == --qf ]] || exit 2
cat "$4"
