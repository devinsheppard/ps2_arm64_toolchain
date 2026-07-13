#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: ${0##*/}"
  echo 'Prepare exact pinned sources and apply the validated job-count patches.'
  echo 'Existing generated upstream worktree changes under build/ are replaced.'
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
source "$ROOT/validation/project-002-pins.sh"

prepare_checkout() {
  local name=$1
  local directory=$2
  local url=$3
  local commit=$4
  local actual
  local type

  mkdir -p "$directory"
  if test ! -d "$directory/.git"; then
    git -C "$directory" init
    git -C "$directory" remote add origin "$url"
  else
    git -C "$directory" remote set-url origin "$url"
  fi
  git -C "$directory" fetch origin "$commit" --depth=1
  type=$(git -C "$directory" cat-file -t FETCH_HEAD)
  if test "$type" != commit; then
    echo "ERROR: $name object $commit has type $type, expected commit" >&2
    exit 1
  fi
  git -C "$directory" checkout --detach -f "$commit"
  actual=$(git -C "$directory" rev-parse HEAD)
  if test "$actual" != "$commit"; then
    echo "ERROR: $name HEAD $actual does not match $commit" >&2
    exit 1
  fi
}

# Apply only the repository-maintained patch for the exact component commit.
apply_component_patch() {
  local component=$1
  local commit=$2
  local repository="$ROOT/build/ps2toolchain/build/ps2toolchain-$component"
  local patch="$ROOT/patches/project-007/ps2toolchain-$component-ps2dev-jobs.patch"

  test "$(git -C "$repository" rev-parse HEAD)" = "$commit"
  test -z "$(git -C "$repository" status --short)"
  git -C "$repository" apply --check "$patch"
  git -C "$repository" apply "$patch"
  git -C "$repository" diff --check
  git -C "$repository" apply --reverse --check "$patch"
}

prepare_checkout ps2toolchain "$ROOT/build/ps2toolchain" \
  https://github.com/ps2dev/ps2toolchain.git \
  "$PS2TOOLCHAIN_DEFAULT_REPO_REF"
prepare_checkout ps2toolchain-dvp "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp" \
  https://github.com/ps2dev/ps2toolchain-dvp.git \
  "$PS2TOOLCHAIN_DVP_DEFAULT_REPO_REF"
prepare_checkout ps2toolchain-iop "$ROOT/build/ps2toolchain/build/ps2toolchain-iop" \
  https://github.com/ps2dev/ps2toolchain-iop.git \
  "$PS2TOOLCHAIN_IOP_DEFAULT_REPO_REF"
prepare_checkout ps2toolchain-ee "$ROOT/build/ps2toolchain/build/ps2toolchain-ee" \
  https://github.com/ps2dev/ps2toolchain-ee.git \
  "$PS2TOOLCHAIN_EE_DEFAULT_REPO_REF"

"$ROOT/scripts/project-003-preclone.sh"

apply_component_patch dvp "$PS2TOOLCHAIN_DVP_DEFAULT_REPO_REF"
apply_component_patch iop "$PS2TOOLCHAIN_IOP_DEFAULT_REPO_REF"
apply_component_patch ee "$PS2TOOLCHAIN_EE_DEFAULT_REPO_REF"

"$ROOT/scripts/project-007-validate-job-patches.sh"
