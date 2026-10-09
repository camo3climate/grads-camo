#!/usr/bin/env bash
set -euo pipefail

PREFIX=${1:-/opt/local}
artifacts=("${PREFIX}/bin/grads")
while IFS= read -r dylib; do artifacts+=("${dylib}"); done < <(
  find "${PREFIX}/lib/grads" -type f -name '*.dylib' -print 2>/dev/null | sort
)

if [[ $(uname -m) != arm64 ]]; then
  echo "error: validation host is not arm64" >&2
  exit 1
fi
for artifact in "${artifacts[@]}"; do
  [[ -f ${artifact} ]] || { echo "error: missing ${artifact}" >&2; exit 1; }
  /usr/bin/file "${artifact}"
  /usr/bin/lipo "${artifact}" -verify_arch arm64
  if /usr/bin/otool -L "${artifact}" | grep -Eq '/usr/local|/opt/homebrew'; then
    echo "error: mixed Homebrew or Intel-prefix dependency in ${artifact}" >&2
    exit 1
  fi
done

echo "All GrADS Mach-O artifacts contain arm64 and use no Homebrew prefix."
