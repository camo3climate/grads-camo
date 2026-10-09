#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PORT_ROOT="${ROOT_DIR}/.macports-local"
PORT_DIR="${PORT_ROOT}/science/grads-camo"
FILES_DIR="${PORT_DIR}/files"

if [[ $(uname -s) != Darwin || $(uname -m) != arm64 ]]; then
  echo "error: the supported macOS build host is native arm64 Darwin" >&2
  exit 1
fi
PORT_BIN="$(command -v port || true)"
if [[ -z ${PORT_BIN} && -x /opt/local/bin/port ]]; then
  PORT_BIN=/opt/local/bin/port
fi
if [[ -z ${PORT_BIN} ]]; then
  echo "error: install MacPorts before preparing the local port" >&2
  exit 1
fi
PORTINDEX_BIN="$(dirname "${PORT_BIN}")/portindex"
PORT_PREFIX="$(cd "$(dirname "${PORT_BIN}")/.." && pwd)"
SOURCES_CONF="${PORT_PREFIX}/etc/macports/sources.conf"

bash "${ROOT_DIR}/tools/check-package-metadata.sh"
# Read the authoritative Portfile list; do not maintain a second patch array.
patches=$(sed -n '/^patchfiles /,/^$/p' "${SCRIPT_DIR}/grads-camo/Portfile.in" |
  sed 's/^patchfiles *//; s/\\//g' | awk 'NF {print $1}')
upstream_version=$(awk '$1=="version" {print $2}' "${SCRIPT_DIR}/grads-camo/Portfile.in")

rm -rf "${PORT_ROOT}"
mkdir -p "${FILES_DIR}"
cp -p "${SCRIPT_DIR}/grads-camo/Portfile.in" "${PORT_DIR}/Portfile"
cp -p "${ROOT_DIR}/SOURCES/grads-${upstream_version}-src.tar.gz" "${FILES_DIR}/"

while IFS= read -r patch_name; do
  cp -p "${ROOT_DIR}/SOURCES/${patch_name}" "${FILES_DIR}/"
done <<< "$patches"
cp -p "${ROOT_DIR}/SOURCES/cairo.m4" "${ROOT_DIR}/SOURCES/libshp.m4" \
  "${ROOT_DIR}/SOURCES/udpt.in" "${FILES_DIR}/"

(cd "${PORT_ROOT}" && "${PORTINDEX_BIN}")
printf 'Local ports tree prepared at %s\n' "${PORT_ROOT}"
printf '\nAdd this line near the top of %s, before the standard MacPorts source:\n' "${SOURCES_CONF}"
printf '  file://%s [nosync]\n' "${PORT_ROOT}"
printf '\nIf sudo port reports Permission denied for this tree under your home directory,\n'
printf 'copy it to a MacPorts-readable location and use that path instead:\n'
printf '  sudo mkdir -p %s/var/macports/sources/grads-camo-local\n' "${PORT_PREFIX}"
printf '  sudo rsync -a --delete %s/ %s/var/macports/sources/grads-camo-local/\n' "${PORT_ROOT}" "${PORT_PREFIX}"
printf '  sudo chown -R root:wheel %s/var/macports/sources/grads-camo-local\n' "${PORT_PREFIX}"
printf '  cd %s/var/macports/sources/grads-camo-local && sudo %s\n' "${PORT_PREFIX}" "${PORTINDEX_BIN}"
printf '  file://%s/var/macports/sources/grads-camo-local [nosync]\n' "${PORT_PREFIX}"
printf '\nThen verify and install with:\n'
printf '  port info grads-camo\n'
printf '  sudo port install grads-camo\n'
