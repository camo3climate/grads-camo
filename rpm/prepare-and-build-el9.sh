#!/usr/bin/env bash
# Prepare AlmaLinux 9 build dependencies, collect diagnostics, and build RPMs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${ROOT_DIR}/logs"
MAIN_LOG="${LOG_DIR}/alma9-validation.log"
PROBE_LOG="${LOG_DIR}/alma9-probe.txt"

if ! grep -Eq '^BuildRequires:[[:space:]]+libXmu-devel([[:space:]]|$)' \
  "${ROOT_DIR}/rpm/grads.spec"; then
  echo "error: outdated EL9 validation kit: libXmu-devel is absent from rpm/grads.spec" >&2
  exit 1
fi

if [[ ${EUID} -eq 0 ]]; then
  echo "error: run this script as an ordinary user; it invokes sudo when needed" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "error: /etc/os-release is unavailable" >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
case "${ID:-}:${VERSION_ID:-}" in
  almalinux:9*) ;;
  *)
    echo "error: this validation wrapper requires AlmaLinux 9; detected ${PRETTY_NAME:-unknown}" >&2
    exit 1
    ;;
esac

mkdir -p "${LOG_DIR}"
exec > >(tee "${MAIN_LOG}") 2>&1

on_exit() {
  local status=$?
  echo
  if [[ ${status} -eq 0 ]]; then
    echo "AlmaLinux 9 validation build completed successfully."
  else
    echo "AlmaLinux 9 validation build failed with status ${status}."
  fi
  echo "Main log:  ${MAIN_LOG}"
  [[ -f "${PROBE_LOG}" ]] && echo "Probe log: ${PROBE_LOG}"
  [[ -f "${ROOT_DIR}/logs/rpmbuild-el9.log" ]] && \
    echo "RPM log:    ${ROOT_DIR}/logs/rpmbuild-el9.log"
}
trap on_exit EXIT

echo "==> Host"
cat /etc/os-release
uname -a

echo
echo "==> Enabling AlmaLinux 9 build repositories"
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb
sudo dnf install -y epel-release
sudo dnf makecache --refresh
dnf repolist --enabled

echo
echo "==> Installing RPM BuildRequires"
sudo dnf builddep -y "${ROOT_DIR}/rpm/grads.spec"

echo
echo "==> Collecting dependency and toolchain details"
"${ROOT_DIR}/rpm/probe-el9.sh" "${PROBE_LOG}"

echo
echo "==> Building GrADS binary and source RPMs"
"${ROOT_DIR}/rpm/build-el9.sh"

mapfile -d '' BINARY_RPMS < <(find "${ROOT_DIR}/.rpmbuild/RPMS" -type f \
  -name 'grads-*.el9.*.rpm' ! -name '*debuginfo*' ! -name '*debugsource*' \
  -print0 | sort -z)
if [[ ${#BINARY_RPMS[@]} -eq 0 ]]; then
  echo "error: no EL9 GrADS binary RPM was produced" >&2
  exit 1
fi

echo
echo "==> Inspecting built binary RPM"
"${ROOT_DIR}/rpm/check-rpm.sh" "${BINARY_RPMS[0]}"

echo
echo "==> Result files"
find "${ROOT_DIR}/.rpmbuild/RPMS" "${ROOT_DIR}/.rpmbuild/SRPMS" \
  -type f -name '*.rpm' -print | sort
