#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 PACKAGE.rpm" >&2
  exit 2
fi

PACKAGE=$1
if [[ ! -f "${PACKAGE}" ]]; then
  echo "error: RPM not found: ${PACKAGE}" >&2
  exit 1
fi

echo "==> Package information"
rpm -qip "${PACKAGE}"
echo
echo "==> Package file list"
rpm -qlp "${PACKAGE}"
echo
echo "==> Signature/digest check"
rpm -K "${PACKAGE}" || true

if command -v grads >/dev/null 2>&1; then
  echo
  echo "==> Installed GrADS configuration"
  grads -blc "q config"
else
  echo
  echo "note: grads is not installed; runtime test skipped"
fi
