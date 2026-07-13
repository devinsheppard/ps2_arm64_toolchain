#!/usr/bin/env bash

set -euo pipefail
set -x

ROOT=$(cd "$(dirname "$0")/.." && pwd)

: "${PS2DEV:?Set PS2DEV to $ROOT/build/ps2dev}"
: "${PS2SDK:?Set PS2SDK to $ROOT/build/ps2dev/ps2sdk}"
: "${PS2DEV_CONFIG_OVERRIDE:?Set PS2DEV_CONFIG_OVERRIDE to $ROOT/validation/project-002-pins.sh}"
: "${PS2DEV_JOBS:?Set PS2DEV_JOBS to a positive integer; 1 is recommended on low-memory ARM64 hosts}"

test "$PS2DEV" = "$ROOT/build/ps2dev"
test "$PS2SDK" = "$ROOT/build/ps2dev/ps2sdk"
test "$PS2DEV_CONFIG_OVERRIDE" = "$ROOT/validation/project-002-pins.sh"
case "$PS2DEV_JOBS" in
  *[!0-9]*|"") echo "ERROR: PS2DEV_JOBS must be a positive integer." >&2; exit 1 ;;
esac
case "$PS2DEV_JOBS" in
  *[1-9]*) ;;
  *) echo "ERROR: PS2DEV_JOBS must be a positive integer." >&2; exit 1 ;;
esac

for component in dvp iop ee; do
  repository="$ROOT/build/ps2toolchain/build/ps2toolchain-$component"
  patch="$ROOT/patches/project-007/ps2toolchain-$component-ps2dev-jobs.patch"
  git -C "$repository" apply --reverse --check "$patch"
  "$repository/toolchain.sh"
done
