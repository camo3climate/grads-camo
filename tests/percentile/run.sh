#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/patched/grads" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
grads_dir="$(cd "$(dirname "$1")" && pwd)"
grads_bin="${grads_dir}/$(basename "$1")"
if [[ ! -x ${grads_bin} ]]; then
  echo "error: GrADS executable not found: ${grads_bin}" >&2
  exit 2
fi

fortran_bin="${GRADS_TEST_FC:-gfortran}"
if ! command -v "${fortran_bin}" >/dev/null 2>&1; then
  echo "error: Fortran compiler not found: ${fortran_bin}" >&2
  exit 2
fi

root="$(cd "${script_dir}/../.." && pwd)"
mkdir -p "${root}/outputs"
test_tmp="$(mktemp -d "${root}/outputs/percentile-test.XXXXXX")"

cp -p "${script_dir}/make-data.f90" "${test_tmp}/"
cp -p "${script_dir}/percentile-test.ctl" "${test_tmp}/"
cp -p "${script_dir}/percentile-monthly.ctl" "${test_tmp}/"
cp -p "${script_dir}/percentile-xyz.ctl" "${test_tmp}/"
cp -p "${script_dir}/check.gs" "${test_tmp}/"
cp -p "${script_dir}/percentile-station.ctl" "${test_tmp}/"
cp -p "${script_dir}/check-station.gs" "${test_tmp}/"

(
  cd "${test_tmp}"
  "${fortran_bin}" -O2 -o make-data make-data.f90
  ./make-data

  if [[ -n ${GADDIR:-} ]]; then
    gad_dir=${GADDIR}
  elif [[ -f ${grads_dir}/../share/grads/udpt ]]; then
    gad_dir="$(cd "${grads_dir}/../share/grads" && pwd)"
  elif [[ -f /opt/local/share/grads/udpt ]]; then
    gad_dir=/opt/local/share/grads
  elif [[ -f /usr/share/grads/udpt ]]; then
    gad_dir=/usr/share/grads
  elif [[ -f ${grads_dir}/../data/udpt ]]; then
    gad_dir="$(cd "${grads_dir}/../data" && pwd)"
  else
    echo "error: set GADDIR to a GrADS data directory containing udpt" >&2
    exit 2
  fi

  env GADDIR="${gad_dir}" "${grads_bin}" -blc 'run check.gs' </dev/null >test.log 2>&1
  if [[ -x ${grads_dir}/stnmap ]]; then
    "${grads_dir}/stnmap" -i percentile-station.ctl >station-map.log 2>&1
    env GADDIR="${gad_dir}" "${grads_bin}" -blc 'run check-station.gs' </dev/null >station.log 2>&1
    if grep -q 'FAIL:' station.log || ! grep -q '^PASS: percentile station rejection' station.log; then
      echo "error: station rejection failed; log retained at ${test_tmp}/station.log" >&2
      sed -n '1,160p' station.log >&2
      exit 1
    fi
    grep '^PASS: percentile station rejection' station.log
  else
    echo 'SKIP: station rejection test (stnmap not found beside GrADS)'
  fi
)

log="${test_tmp}/test.log"
if grep -q 'FAIL:' "${log}" || ! grep -q '^PASS: percentile regression' "${log}"; then
  echo "error: percentile regression failed; log retained at ${log}" >&2
  sed -n '1,320p' "${log}" >&2
  exit 1
fi
grep '^PASS: percentile regression' "${log}"
echo "Results retained at ${test_tmp}"
