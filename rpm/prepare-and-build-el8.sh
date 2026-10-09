#!/usr/bin/env bash
# Prepare EL8 build dependencies and build RPMs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${ROOT_DIR}/logs"
MAIN_LOG="${LOG_DIR}/alma8-validation.log"

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
  almalinux:8*|rocky:8*|rhel:8*|centos:8*) ;;
  *)
    echo "error: this validation wrapper requires an EL8-compatible host; detected ${PRETTY_NAME:-unknown}" >&2
    exit 1
    ;;
esac

mkdir -p "${LOG_DIR}"
exec > >(tee "${MAIN_LOG}") 2>&1

on_exit() {
  local status=$?
  echo
  if [[ ${status} -eq 0 ]]; then
    echo "EL8 validation build completed successfully."
  else
    echo "EL8 validation build failed with status ${status}."
  fi
  echo "Main log: ${MAIN_LOG}"
  [[ -f "${ROOT_DIR}/logs/rpmbuild.log" ]] && \
    echo "RPM log:  ${ROOT_DIR}/logs/rpmbuild.log"
}
trap on_exit EXIT

enable_repo_if_present() {
  local repo=$1
  if dnf repolist all | awk '{print $1}' | grep -qx "${repo}"; then
    sudo dnf config-manager --set-enabled "${repo}"
  fi
}

echo "==> Host"
cat /etc/os-release
uname -a

echo
echo "==> Enabling EL8 build repositories"
sudo dnf install -y dnf-plugins-core
sudo dnf install -y epel-release
enable_repo_if_present powertools
enable_repo_if_present PowerTools
sudo dnf makecache --refresh
dnf repolist --enabled

echo
echo "==> Installing RPM BuildRequires"
sudo dnf install -y rpm-build rpmdevtools autoconf automake libtool gcc gcc-c++ make
sudo dnf builddep -y "${ROOT_DIR}/rpm/grads.spec"

echo
echo "==> Building GrADS binary and source RPMs"
"${ROOT_DIR}/rpm/build-el8.sh"

mapfile -d '' BINARY_RPMS < <(find "${ROOT_DIR}/.rpmbuild/RPMS" -type f \
  -name 'grads-*.el8.*.rpm' ! -name '*debuginfo*' ! -name '*debugsource*' \
  -print0 | sort -z)
if [[ ${#BINARY_RPMS[@]} -eq 0 ]]; then
  echo "error: no EL8 GrADS binary RPM was produced" >&2
  exit 1
fi

echo
echo "==> Inspecting built binary RPM"
"${ROOT_DIR}/rpm/check-rpm.sh" "${BINARY_RPMS[0]}"

echo
echo "==> Result files"
find "${ROOT_DIR}/.rpmbuild/RPMS" "${ROOT_DIR}/.rpmbuild/SRPMS" \
  -type f -name '*.rpm' -print | sort
