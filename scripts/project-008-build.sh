#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: ${0##*/}"
  echo 'Build the pinned DVP, IOP, and EE toolchains in official component order.'
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

: "${PS2DEV:?Set PS2DEV to $ROOT/build/ps2dev}"
: "${PS2SDK:?Set PS2SDK to $ROOT/build/ps2dev/ps2sdk}"
: "${PS2DEV_CONFIG_OVERRIDE:?Set PS2DEV_CONFIG_OVERRIDE to $ROOT/validation/project-002-pins.sh}"
: "${PS2DEV_JOBS:?Set PS2DEV_JOBS to a positive integer; 1 is recommended on low-memory ARM64 hosts}"

test "$PS2DEV" = "$ROOT/build/ps2dev" || {
  echo "ERROR: PS2DEV must equal $ROOT/build/ps2dev" >&2
  exit 1
}
test "$PS2SDK" = "$ROOT/build/ps2dev/ps2sdk" || {
  echo "ERROR: PS2SDK must equal $ROOT/build/ps2dev/ps2sdk" >&2
  exit 1
}
test "$PS2DEV_CONFIG_OVERRIDE" = "$ROOT/validation/project-002-pins.sh" || {
  echo "ERROR: PS2DEV_CONFIG_OVERRIDE must equal $ROOT/validation/project-002-pins.sh" >&2
  exit 1
}
case "$PS2DEV_JOBS" in
  *[!0-9]*|"") echo "ERROR: PS2DEV_JOBS must be a positive integer." >&2; exit 1 ;;
esac
case "$PS2DEV_JOBS" in
  *[1-9]*) ;;
  *) echo "ERROR: PS2DEV_JOBS must be a positive integer." >&2; exit 1 ;;
esac

# Invoke the official patched component workflows directly. The official
# top-level wrapper would forcibly check out and erase the explicit patches.
for component in dvp iop ee; do
  repository="$ROOT/build/ps2toolchain/build/ps2toolchain-$component"
  patch="$ROOT/patches/project-007/ps2toolchain-$component-ps2dev-jobs.patch"
  git -C "$repository" apply --reverse --check "$patch"
  "$repository/toolchain.sh"
done
