#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: ${0##*/}"
  echo 'Audit pinned Git object types and resolve each object to a commit.'
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
BUILD="$ROOT/build/ps2toolchain/build"

audit_object()
{
  local name=$1
  local directory=$2
  local url=$3
  local object=$4
  local type
  local commit

  mkdir -p "$directory"
  if test ! -d "$directory/.git"; then
    git -C "$directory" init
    git -C "$directory" remote add origin "$url"
  else
    git -C "$directory" remote set-url origin "$url"
  fi
  git -C "$directory" fetch origin "$object" --depth=1
  type=$(git -C "$directory" cat-file -t FETCH_HEAD)
  case "$type" in
    commit|tag) ;;
    *) printf 'ERROR: %s object %s has rejected type %s\n' "$name" "$object" "$type" >&2; exit 1 ;;
  esac
  commit=$(git -C "$directory" rev-parse --verify 'FETCH_HEAD^{commit}')
  test "$(git -C "$directory" cat-file -t "$commit")" = commit
  printf '%s object=%s type=%s commit=%s\n' "$name" "$object" "$type" "$commit"
}

audit_object ps2toolchain-dvp "$BUILD/ps2toolchain-dvp" https://github.com/ps2dev/ps2toolchain-dvp.git 54d25004c9d9d0d10d5f320703a8fe7c6ddb684a
audit_object ps2toolchain-iop "$BUILD/ps2toolchain-iop" https://github.com/ps2dev/ps2toolchain-iop.git 8129f3ab5f6beb63e0ec1ed3627ef9b985750729
audit_object ps2toolchain-ee "$BUILD/ps2toolchain-ee" https://github.com/ps2dev/ps2toolchain-ee.git 480a5f31c644107ceddcdadf6ee5502fb2cd14ff

audit_object dvp-binutils "$BUILD/ps2toolchain-dvp/build/binutils-gdb" https://github.com/ps2dev/binutils-gdb.git 3eb45ea37f0efd498d1de3cf9562de07197aefa8
audit_object dvp-masp "$BUILD/ps2toolchain-dvp/build/masp" https://github.com/ps2dev/masp.git ddb4fa5fb1546e74662979a4e417217c27201c3f
audit_object dvp-openvcl "$BUILD/ps2toolchain-dvp/build/openvcl" https://github.com/ps2dev/openvcl.git 5d432985669f9ed2ecde7058a8d2faeb0396b2d4

audit_object iop-binutils "$BUILD/ps2toolchain-iop/build/binutils-gdb" https://sourceware.org/git/binutils-gdb.git 48324fde1e284293dd3d570dba597cb644921c92
audit_object iop-gcc "$BUILD/ps2toolchain-iop/build/gcc" https://gcc.gnu.org/git/gcc.git 5115c7e447fc07457443df874bf57840e8316d5f

audit_object ee-binutils "$BUILD/ps2toolchain-ee/build/binutils-gdb" https://github.com/ps2dev/binutils-gdb.git 616e51fa6ed9d1e8f4bda7d0087fac30c5398aa9
audit_object ee-gcc "$BUILD/ps2toolchain-ee/build/gcc" https://github.com/ps2dev/gcc.git df77d03bc1bd5765b40de554918a5ff541202548
audit_object ee-newlib "$BUILD/ps2toolchain-ee/build/newlib" https://github.com/ps2dev/newlib.git 58fb6406408a541e0c826f47487315b485d4db56
audit_object ee-pthread "$BUILD/ps2toolchain-ee/build/pthread-embedded" https://github.com/ps2dev/pthread-embedded.git b1746fd2b52d5aeafc1173761eb50e0958e8994b
