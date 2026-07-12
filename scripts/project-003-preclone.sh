#!/bin/bash

set -euo pipefail
set -x

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TOOLCHAIN_BUILD="$ROOT/build/ps2toolchain/build"

prepare_checkout()
{
  local directory=$1
  local url=$2
  local commit=$3
  local actual

  mkdir -p "$directory"
  if test ! -d "$directory/.git"; then
    git -C "$directory" init
    git -C "$directory" remote add origin "$url"
  else
    git -C "$directory" remote set-url origin "$url"
  fi
  git -C "$directory" fetch origin "$commit" --depth=1
  git -C "$directory" checkout --detach -f FETCH_HEAD
  actual=$(git -C "$directory" rev-parse HEAD)
  test "$actual" = "$commit"
  printf '%s %s\n' "$directory" "$actual"
}

prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/binutils-gdb" \
  https://github.com/ps2dev/binutils-gdb.git \
  3eb45ea37f0efd498d1de3cf9562de07197aefa8
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/masp" \
  https://github.com/ps2dev/masp.git \
  ddb4fa5fb1546e74662979a4e417217c27201c3f
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-dvp/build/openvcl" \
  https://github.com/ps2dev/openvcl.git \
  5d432985669f9ed2ecde7058a8d2faeb0396b2d4

prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-iop/build/binutils-gdb" \
  https://sourceware.org/git/binutils-gdb.git \
  48324fde1e284293dd3d570dba597cb644921c92
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-iop/build/gcc" \
  https://gcc.gnu.org/git/gcc.git \
  dcd428f94ffb464418f996ffb70dfa398f5caa3f

prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/binutils-gdb" \
  https://github.com/ps2dev/binutils-gdb.git \
  616e51fa6ed9d1e8f4bda7d0087fac30c5398aa9
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/gcc" \
  https://github.com/ps2dev/gcc.git \
  df77d03bc1bd5765b40de554918a5ff541202548
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/newlib" \
  https://github.com/ps2dev/newlib.git \
  58fb6406408a541e0c826f47487315b485d4db56
prepare_checkout "$TOOLCHAIN_BUILD/ps2toolchain-ee/build/pthread-embedded" \
  https://github.com/ps2dev/pthread-embedded.git \
  b1746fd2b52d5aeafc1173761eb50e0958e8994b
