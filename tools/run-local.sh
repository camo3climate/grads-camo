#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
install=${CAMO_LOCAL_INSTALL:-"$root/work/macos-local/install"}
if [[ ! -x "$install/bin/grads" || ! -r "$install/share/grads/udpt" ]]; then
  echo "No complete local GrADS installation at: $install" >&2
  echo "Run tools/build-macos-local.sh or set CAMO_LOCAL_INSTALL to its install directory." >&2
  exit 2
fi
export GADDIR="$install/share/grads"
export GASCRP="$GADDIR${GASCRP:+ $GASCRP}"
exec "$install/bin/grads" "$@"
