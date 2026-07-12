#!/bin/bash

set -euo pipefail
set -x

ROOT=$(cd "$(dirname "$0")/.." && pwd)

apply_patch()
{
  local repository=$1
  local commit=$2
  local patch=$3

  test "$(git -C "$repository" rev-parse HEAD)" = "$commit"
  test -z "$(git -C "$repository" status --short)"
  git -C "$repository" apply --check "$patch"
  git -C "$repository" apply "$patch"
}

apply_patch "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp" \
  54d25004c9d9d0d10d5f320703a8fe7c6ddb684a \
  "$ROOT/patches/ps2toolchain-dvp-ps2dev-jobs.patch"
apply_patch "$ROOT/build/ps2toolchain/build/ps2toolchain-iop" \
  8129f3ab5f6beb63e0ec1ed3627ef9b985750729 \
  "$ROOT/patches/ps2toolchain-iop-ps2dev-jobs.patch"
apply_patch "$ROOT/build/ps2toolchain/build/ps2toolchain-ee" \
  480a5f31c644107ceddcdadf6ee5502fb2cd14ff \
  "$ROOT/patches/ps2toolchain-ee-ps2dev-jobs.patch"
