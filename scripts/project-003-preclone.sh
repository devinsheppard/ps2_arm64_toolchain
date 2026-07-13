#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: ${0##*/}"
  echo 'Pre-clone and verify all pinned nested toolchain repositories.'
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
TOOLCHAIN_BUILD="$ROOT/build/ps2toolchain/build"
source "$ROOT/validation/project-002-pins.sh"

prepare_checkout()
{
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
  type=$(git -C "$directory" cat-file -t FETCH_HEAD) || {
    printf 'ERROR: %s object %s could not be resolved in %s\n' "$name" "$commit" "$url" >&2
    exit 1
  }
  if test "$type" != commit; then
    printf 'ERROR: %s object %s in %s has type %s, expected commit\n' "$name" "$commit" "$url" "$type" >&2
    exit 1
  fi
  git -C "$directory" checkout --detach -f "$commit"
  actual=$(git -C "$directory" rev-parse HEAD)
  if test "$actual" != "$commit"; then
    printf 'ERROR: %s checkout HEAD %s does not match commit %s\n' "$name" "$actual" "$commit" >&2
    exit 1
  fi
  printf '%s %s %s\n' "$name" "$directory" "$actual"
}

prepare_checkout dvp-binutils "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/binutils-gdb" \
  https://github.com/ps2dev/binutils-gdb.git \
  "$PS2TOOLCHAIN_DVP_BINUTILS_DEFAULT_REPO_REF"
prepare_checkout dvp-masp "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/masp" \
  https://github.com/ps2dev/masp.git \
  "$PS2TOOLCHAIN_DVP_MASP_DEFAULT_REPO_REF"
prepare_checkout dvp-openvcl "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/openvcl" \
  https://github.com/ps2dev/openvcl.git \
  "$PS2TOOLCHAIN_DVP_OPENVCL_DEFAULT_REPO_REF"

prepare_checkout iop-binutils "$TOOLCHAIN_BUILD/ps2toolchain-iop/build/binutils-gdb" \
  https://sourceware.org/git/binutils-gdb.git \
  "$PS2TOOLCHAIN_IOP_BINUTILS_DEFAULT_REPO_REF"
prepare_checkout iop-gcc "$TOOLCHAIN_BUILD/ps2toolchain-iop/build/gcc" \
  https://gcc.gnu.org/git/gcc.git \
  "$PS2TOOLCHAIN_IOP_GCC_DEFAULT_REPO_REF"

prepare_checkout ee-binutils "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/binutils-gdb" \
  https://github.com/ps2dev/binutils-gdb.git \
  "$PS2TOOLCHAIN_EE_BINUTILS_DEFAULT_REPO_REF"
prepare_checkout ee-gcc "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/gcc" \
  https://github.com/ps2dev/gcc.git \
  "$PS2TOOLCHAIN_EE_GCC_DEFAULT_REPO_REF"
prepare_checkout ee-newlib "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/newlib" \
  https://github.com/ps2dev/newlib.git \
  "$PS2TOOLCHAIN_EE_NEWLIB_DEFAULT_REPO_REF"
prepare_checkout ee-pthread "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/pthread-embedded" \
  https://github.com/ps2dev/pthread-embedded.git \
  "$PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_DEFAULT_REPO_REF"
