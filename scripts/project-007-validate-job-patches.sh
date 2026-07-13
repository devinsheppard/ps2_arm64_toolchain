#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: ${0##*/}"
  echo 'Validate the applied Project 007 job-count patches.'
}

if test "${1:-}" = -h || test "${1:-}" = --help; then
  usage
  exit 0
fi
if test "$#" -ne 0; then
  usage >&2
  exit 2
fi

set -x

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEFAULT_JOBS=$(getconf _NPROCESSORS_ONLN)

validate_component() {
  local component=$1
  local expected_scripts=$2
  local repo="$ROOT/build/ps2toolchain/build/ps2toolchain-$component"
  local config="$repo/config/ps2toolchain-$component-config.sh"
  local actual_scripts
  local output

  test -z "$(git -C "$repo" diff --name-only --diff-filter=ACDMRTUXB -- . ':!config/*' ':!scripts/*')"
  test "$(git -C "$repo" diff --name-only -- 'scripts/*.sh' | wc -l)" -eq "$expected_scripts"
  test "$(git -C "$repo" diff --name-only -- 'config/*.sh' | wc -l)" -eq 1
  git -C "$repo" diff --check

  actual_scripts=$(grep -R -l -F 'PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}' "$repo/scripts" | wc -l)
  test "$actual_scripts" -eq "$expected_scripts"
  test -z "$(grep -R -l -F 'PROC_NR=$(getconf _NPROCESSORS_ONLN)' "$repo/scripts" || true)"

  (
    unset PS2DEV_JOBS
    PS2DEV_CONFIG_OVERRIDE=/does/not/exist
    source "$config"
    PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}
    test "$PROC_NR" -eq "$DEFAULT_JOBS"
  )

  (
    PS2DEV_JOBS=
    PS2DEV_CONFIG_OVERRIDE=/does/not/exist
    source "$config"
    PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}
    test "$PROC_NR" -eq "$DEFAULT_JOBS"
  )

  (
    PS2DEV_JOBS=1
    PS2DEV_CONFIG_OVERRIDE=/does/not/exist
    source "$config"
    PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}
    test "$PROC_NR" -eq 1
  )

  local invalid
  for invalid in 0 00 abc 1x -1; do
    if output=$(PS2DEV_JOBS=$invalid PS2DEV_CONFIG_OVERRIDE=/does/not/exist bash -c "source '$config'" 2>&1); then
      echo "ERROR: $component accepted invalid PS2DEV_JOBS=$invalid" >&2
      exit 1
    fi
    test "$output" = "ERROR: PS2DEV_JOBS must be a positive integer."
  done
}

validate_component dvp 3
validate_component iop 2
validate_component ee 6

echo "All Project 007 job-count patch behavior checks passed."
