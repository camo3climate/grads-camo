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

GRADS_RUNTIME_TIMEOUT=${GRADS_RUNTIME_TIMEOUT:-30}
PACKAGE_VERSION=$(rpm -qp --qf '%{VERSION}' "${PACKAGE}")
PACKAGE_RELEASE=$(rpm -qp --qf '%{RELEASE}' "${PACKAGE}")
CAMO_VERSION=$(printf '%s\n' "${PACKAGE_RELEASE}" | sed -E 's/^[0-9]+\.(camo[0-9]+\.[0-9]+).*/\1/')

run_grads_check() {
  local command=$1

  if command -v timeout >/dev/null 2>&1; then
    timeout "${GRADS_RUNTIME_TIMEOUT}" grads -blc "${command}" </dev/null
  else
    grads -blc "${command}" </dev/null
  fi
}

echo "==> Package information"
rpm -qip "${PACKAGE}"
echo
echo "==> Package file list"
PACKAGE_FILES=$(rpm -qlp "${PACKAGE}")
printf '%s\n' "${PACKAGE_FILES}"
printf '%s\n' "${PACKAGE_FILES}" | grep -q '/usr/share/grads/udunits2.xml$'
printf '%s\n' "${PACKAGE_FILES}" | grep -Eq '/usr/lib(64)?/grads/.*\.so'
echo
echo "==> Automatically generated runtime requirements"
rpm -qpR "${PACKAGE}" | sort
echo
echo "==> Signature/digest check"
rpm -K "${PACKAGE}" || true

if command -v grads >/dev/null 2>&1; then
  echo
  echo "==> Installed GrADS configuration"
  INSTALLED_VERSION=$(rpm -q --qf '%{VERSION}' grads)
  INSTALLED_RELEASE=$(rpm -q --qf '%{RELEASE}' grads)
  if [[ "${INSTALLED_VERSION}-${INSTALLED_RELEASE}" != "${PACKAGE_VERSION}-${PACKAGE_RELEASE}" ]]; then
    echo "error: installed grads ${INSTALLED_VERSION}-${INSTALLED_RELEASE} does not match checked RPM ${PACKAGE_VERSION}-${PACKAGE_RELEASE}" >&2
    exit 1
  fi
  CONFIG_OUTPUT=$(run_grads_check "q config")
  printf '%s\n' "${CONFIG_OUTPUT}"
  printf '%s\n' "${CONFIG_OUTPUT}" | grep -q "Version ${PACKAGE_VERSION}"
  printf '%s\n' "${CONFIG_OUTPUT}" | grep -q "CAMO build ${CAMO_VERSION}"
  run_grads_check "help camo"
else
  echo
  echo "note: grads is not installed; runtime test skipped"
fi
