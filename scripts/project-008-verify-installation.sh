#!/usr/bin/env bash

set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/validation/project-002-pins.sh"

failures=0
warnings=0

pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
warn() { printf 'WARN: %s\n' "$*" >&2; warnings=$((warnings + 1)); }

check_equal() {
  local label=$1
  local actual=$2
  local expected=$3
  if test "$actual" = "$expected"; then
    pass "$label = $expected"
  else
    fail "$label is '$actual', expected '$expected'"
  fi
}

echo '== Host =='
architecture=$(dpkg --print-architecture 2>/dev/null || uname -m)
case "$architecture" in
  arm64|aarch64) pass "ARM64 architecture ($architecture)" ;;
  *) fail "architecture is $architecture, expected arm64/aarch64" ;;
esac

if test -r /etc/os-release; then
  # shellcheck disable=SC1091
  source /etc/os-release
  printf 'OS: %s\n' "${PRETTY_NAME:-unknown}"
  test "${ID:-}" = ubuntu || fail "OS ID is ${ID:-unset}, expected ubuntu"
else
  fail '/etc/os-release is unavailable'
fi
uname -a

memory_kib=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
swap_kib=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
available_kib=$(df -Pk "$ROOT" | awk 'NR == 2 {print $4}')
printf 'Memory: %s KiB\nSwap: %s KiB\nDisk available: %s KiB\n' \
  "$memory_kib" "$swap_kib" "$available_kib"

if test "$memory_kib" -ge 3500000; then
  pass 'at least 3.5 million KiB RAM'
else
  warn 'less RAM than the verified 3.7 GiB host; keep PS2DEV_JOBS=1'
fi
if test "$swap_kib" -ge 1000000; then
  pass 'at least approximately 1 GiB configured swap'
else
  warn 'less swap than the verified 1 GiB host; consult the system administrator before building'
fi
if test "$available_kib" -ge 10485760; then
  pass 'at least 10 GiB free disk space'
else
  warn 'less than 10 GiB free; a clean build may not have enough workspace'
fi

echo '== Ubuntu packages =='
packages=(
  gcc make patch git wget texinfo flex bison libgsl-dev libgmp-dev
  libmpfr-dev libmpc-dev gettext cmake file time bsdutils
)
for package in "${packages[@]}"; do
  status=$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)
  if test "$status" = installed; then
    version=$(dpkg-query -W -f='${Version}' "$package")
    pass "$package $version"
  else
    fail "Ubuntu package $package is not installed"
  fi
done

echo '== Environment =='
expected_ps2dev="$ROOT/build/ps2dev"
expected_ps2sdk="$expected_ps2dev/ps2sdk"
expected_override="$ROOT/validation/project-002-pins.sh"
check_equal PS2DEV "${PS2DEV:-unset}" "$expected_ps2dev"
check_equal PS2SDK "${PS2SDK:-unset}" "$expected_ps2sdk"
check_equal PS2DEV_CONFIG_OVERRIDE "${PS2DEV_CONFIG_OVERRIDE:-unset}" "$expected_override"
case "${PS2DEV_JOBS:-}" in
  *[!0-9]*|"") fail 'PS2DEV_JOBS is not a positive integer' ;;
  *[1-9]*) pass "PS2DEV_JOBS=${PS2DEV_JOBS}" ;;
  *) fail 'PS2DEV_JOBS is zero' ;;
esac
install_root=${PS2DEV:-$expected_ps2dev}
for directory in "$install_root/bin" "$install_root/dvp/bin" "$install_root/iop/bin" "$install_root/ee/bin"; do
  case ":$PATH:" in
    *":$directory:"*) pass "PATH contains $directory" ;;
    *) fail "PATH does not contain $directory" ;;
  esac
done

echo '== Repository inputs =='
required_files=(
  validation/project-002-pins.sh
  validation/project-008-expected-executables.txt
  patches/project-007/ps2toolchain-dvp-ps2dev-jobs.patch
  patches/project-007/ps2toolchain-iop-ps2dev-jobs.patch
  patches/project-007/ps2toolchain-ee-ps2dev-jobs.patch
  scripts/project-003-preclone.sh
  scripts/project-007-validate-job-patches.sh
  scripts/project-008-prepare.sh
  scripts/project-008-build.sh
  logs/project-007-build.log
  logs/project-007-binary-validation-final.log
)
for relative in "${required_files[@]}"; do
  test -f "$ROOT/$relative" && pass "$relative" || fail "missing $relative"
done

check_repo() {
  local name=$1
  local directory=$2
  local expected=$3
  if test ! -e "$directory/.git"; then
    fail "$name repository is missing at $directory"
    return
  fi
  actual=$(git -C "$directory" rev-parse HEAD 2>/dev/null || true)
  check_equal "$name commit" "$actual" "$expected"
}

check_repo ps2toolchain "$ROOT/build/ps2toolchain" "$PS2TOOLCHAIN_DEFAULT_REPO_REF"
check_repo ps2toolchain-dvp "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp" "$PS2TOOLCHAIN_DVP_DEFAULT_REPO_REF"
check_repo ps2toolchain-iop "$ROOT/build/ps2toolchain/build/ps2toolchain-iop" "$PS2TOOLCHAIN_IOP_DEFAULT_REPO_REF"
check_repo ps2toolchain-ee "$ROOT/build/ps2toolchain/build/ps2toolchain-ee" "$PS2TOOLCHAIN_EE_DEFAULT_REPO_REF"

check_repo dvp-binutils "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp/build/binutils-gdb" "$PS2TOOLCHAIN_DVP_BINUTILS_DEFAULT_REPO_REF"
check_repo dvp-masp "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp/build/masp" "$PS2TOOLCHAIN_DVP_MASP_DEFAULT_REPO_REF"
check_repo dvp-openvcl "$ROOT/build/ps2toolchain/build/ps2toolchain-dvp/build/openvcl" "$PS2TOOLCHAIN_DVP_OPENVCL_DEFAULT_REPO_REF"
check_repo iop-binutils "$ROOT/build/ps2toolchain/build/ps2toolchain-iop/build/binutils-gdb" "$PS2TOOLCHAIN_IOP_BINUTILS_DEFAULT_REPO_REF"
check_repo iop-gcc "$ROOT/build/ps2toolchain/build/ps2toolchain-iop/build/gcc" "$PS2TOOLCHAIN_IOP_GCC_DEFAULT_REPO_REF"
check_repo ee-binutils "$ROOT/build/ps2toolchain/build/ps2toolchain-ee/build/binutils-gdb" "$PS2TOOLCHAIN_EE_BINUTILS_DEFAULT_REPO_REF"
check_repo ee-gcc "$ROOT/build/ps2toolchain/build/ps2toolchain-ee/build/gcc" "$PS2TOOLCHAIN_EE_GCC_DEFAULT_REPO_REF"
check_repo ee-newlib "$ROOT/build/ps2toolchain/build/ps2toolchain-ee/build/newlib" "$PS2TOOLCHAIN_EE_NEWLIB_DEFAULT_REPO_REF"
check_repo ee-pthread "$ROOT/build/ps2toolchain/build/ps2toolchain-ee/build/pthread-embedded" "$PS2TOOLCHAIN_EE_PTHREAD_EMBEDDED_DEFAULT_REPO_REF"

for component in dvp iop ee; do
  repository="$ROOT/build/ps2toolchain/build/ps2toolchain-$component"
  patch="$ROOT/patches/project-007/ps2toolchain-$component-ps2dev-jobs.patch"
  if git -C "$repository" apply --reverse --check "$patch" >/dev/null 2>&1; then
    pass "$component PS2DEV_JOBS patch is applied"
  else
    fail "$component PS2DEV_JOBS patch is not exactly applied"
  fi
done

echo '== Installed executables =='
expected_inventory=$(sort "$ROOT/validation/project-008-expected-executables.txt")
actual_inventory=$(
  {
    find "$install_root/bin" -maxdepth 1 \( -type f -o -type l \) -printf 'bin/%f\n'
    find "$install_root/dvp/bin" -maxdepth 1 \( -type f -o -type l \) -printf 'dvp/bin/%f\n'
    find "$install_root/iop/bin" -maxdepth 1 \( -type f -o -type l \) -printf 'iop/bin/%f\n'
    find "$install_root/ee/bin" -maxdepth 1 \( -type f -o -type l \) -printf 'ee/bin/%f\n'
  } | sort
)
if test "$actual_inventory" = "$expected_inventory"; then
  pass 'installed executable inventory exactly matches the 76-entry manifest'
else
  fail 'installed executable inventory differs from the manifest'
  diff -u <(printf '%s\n' "$expected_inventory") <(printf '%s\n' "$actual_inventory") || true
fi

while IFS= read -r relative; do
  test -n "$relative" || continue
  executable="$install_root/$relative"
  if test ! -x "$executable"; then
    fail "missing executable $executable"
    continue
  fi
  resolved=$(realpath "$executable")
  case "$resolved" in
    "$ROOT"/build/*) ;;
    *) fail "$executable resolves outside build: $resolved"; continue ;;
  esac
  description=$(file -L -b "$executable")
  case "$description" in
    *'ARM aarch64'*) pass "$relative ($description)" ;;
    *'shell script'*'executable'*) pass "$relative (host-independent $description)" ;;
    *) fail "$relative is neither native AArch64 nor an executable shell helper: $description" ;;
  esac
done < "$ROOT/validation/project-008-expected-executables.txt"

echo '== Version execution =='
version_commands=(
  "$install_root/bin/masp --version"
  "$install_root/bin/openvcl --version"
  "$install_root/dvp/bin/dvp-as --version"
  "$install_root/iop/bin/mipsel-none-elf-as --version"
  "$install_root/iop/bin/mipsel-none-elf-ld --version"
  "$install_root/iop/bin/mipsel-none-elf-gcc --version"
  "$install_root/iop/bin/mipsel-none-elf-g++ --version"
  "$install_root/ee/bin/mips64r5900el-ps2-elf-as --version"
  "$install_root/ee/bin/mips64r5900el-ps2-elf-ld --version"
  "$install_root/ee/bin/mips64r5900el-ps2-elf-gcc --version"
  "$install_root/ee/bin/mips64r5900el-ps2-elf-g++ --version"
)
for command in "${version_commands[@]}"; do
  if bash -c "$command"; then
    pass "$command"
  else
    fail "$command"
  fi
done

printf 'SUMMARY: failures=%d warnings=%d\n' "$failures" "$warnings"
test "$failures" -eq 0
