# PS2 ARM64 Toolchain

This repository provides a reproducible procedure for building the official
PlayStation 2 DVP, IOP, and EE cross-toolchains natively on ARM64 Ubuntu. All
official upstream repositories are pinned to immutable commits. The only
upstream-source changes are explicit, validated patches that add a configurable
build job count while preserving the official default behavior.

## Verified platform

The complete procedure was verified on:

- Raspberry Pi 4 Model B Rev 1.2;
- ARM64/AArch64;
- Ubuntu 26.04 LTS (Resolute Raccoon);
- Linux `7.0.0-1009-raspi`;
- 3.7 GiB usable RAM and 1.0 GiB configured swap.

Project 007 completed the native build in 9:21:11 with
`PS2DEV_JOBS=1`. GNU `time -v` reported a maximum resident set of
2,096,896 KiB (about 2.0 GiB). No OOM or ARM64-specific compilation failure
occurred.

Other ARM64 hardware and Ubuntu releases may work but have not been verified.
This repository does not claim official upstream ARM64 support.

## Requirements

Start with at least 10 GiB of free workspace. The cleaned verified installation
used approximately 6.3 GiB for source/build trees and 436 MiB for the installed
toolchain. More space may be needed while compilation is active.

Install the packages used by the successful Ubuntu build:

```bash
sudo apt-get update
sudo apt-get install -y \
  gcc make patch git wget texinfo flex bison \
  libgsl-dev libgmp-dev libmpfr-dev libmpc-dev gettext \
  cmake file time bsdutils
```

The build succeeded with 1.0 GiB of configured swap. On a machine with about
4 GiB RAM, use `PS2DEV_JOBS=1` and keep at least approximately 1 GiB of swap
available to the system. Swap is system configuration: consult the machine
administrator before adding or resizing it. This repository does not create or
modify swap.

## Clone and environment

Clone this repository, enter it, and define repository-local installation
paths:

```bash
git clone https://github.com/devinsheppard/ps2_arm64_toolchain.git
cd ps2_arm64_toolchain

export PS2DEV="$PWD/build/ps2dev"
export PS2SDK="$PS2DEV/ps2sdk"
export PS2DEV_CONFIG_OVERRIDE="$PWD/validation/project-002-pins.sh"
export PS2DEV_JOBS=1
export PATH="$PS2DEV/bin:$PS2DEV/dvp/bin:$PS2DEV/iop/bin:$PS2DEV/ee/bin:$PATH"
```

`PS2DEV_JOBS=1` is the recommended setting for low-memory ARM64 systems. A
positive integer may be selected on a better-provisioned host. When the
variable is unset or empty, the patches preserve the official upstream
behavior and use `getconf _NPROCESSORS_ONLN`.

All installation and build output stays below `build/`:

```text
build/
├── ps2dev/                 installed DVP, IOP, and EE tools
└── ps2toolchain/
    └── build/
        ├── ps2toolchain-dvp/
        ├── ps2toolchain-iop/
        └── ps2toolchain-ee/
```

## Prepare exact sources

The preparer initializes the official repositories, fetches only the immutable
commits from `validation/project-002-pins.sh`, verifies commit object types and
detached `HEAD` values, applies the explicit Project 007 patches, and runs patch
behavior validation:

```bash
script -q -e -c './scripts/project-008-prepare.sh' \
  logs/project-008-prepare.log
```

This command deliberately replaces changes within the generated upstream
worktrees under `build/`. It does not edit any upstream source silently: the
only changes applied are the three patches documented in
`patches/project-007/README.md`.

## Build

Run the pinned official DVP, IOP, and EE component workflows in the same order
as the successful Project 007 build:

```bash
script -q -e -c '/usr/bin/time -v ./scripts/project-008-build.sh' \
  logs/project-008-build.log
```

Do not run the top-level upstream wrapper after applying the patches: that
wrapper forcibly checks out the component repositories and would remove the
explicit repository-maintained changes. The local build wrapper invokes the
three official component `toolchain.sh` scripts directly and changes no build
flags, compiler sources, component ordering, or installation paths.

On the verified Raspberry Pi, allow about 9.5 hours. Performance varies with
storage, cooling, and CPU speed. Preserve the complete terminal transcript; do
not treat warnings as failures unless the command returns nonzero.

## Verify the installation

With the environment above still exported, run the read-only verifier:

```bash
script -q -e -c './scripts/project-008-verify-installation.sh' \
  logs/project-008-verification.log
```

It checks:

- Ubuntu packages, architecture, RAM, swap, and free disk space;
- `PS2DEV`, `PS2SDK`, `PS2DEV_CONFIG_OVERRIDE`, `PS2DEV_JOBS`, and `PATH`;
- every top-level, component, and nested repository commit;
- exact application of all three job-count patches;
- all 76 executables in the verified installation manifest;
- repository-local realpaths and native AArch64 executable format;
- representative DVP, IOP, and EE version commands.

Expected primary versions are:

```text
MASP, the Assembly Preprocessor 0.1.16
OpenVCL Version 0.4.0
GNU Binutils 2.45.1
mipsel-none-elf-gcc (GCC) 15.2.0
mips64r5900el-ps2-elf-gcc (GCC) 15.2.0
```

The verifier exits nonzero if any required package, environment value,
repository commit, patch, executable, path, architecture, or version command
is invalid. Resource values below the verified recommendations are warnings so
the script remains useful on other ARM64 machines.

## Troubleshooting

- **A process is killed or Make reports error 137:** This indicates likely
  memory exhaustion. Confirm `PS2DEV_JOBS=1`, inspect the kernel journal, and
  check RAM/swap with `free -h`. Project 004 OOM-killed GCC with four jobs;
  Project 007 completed with one.
- **`PS2DEV_JOBS must be a positive integer`:** Set it to a nonzero decimal
  integer. Empty uses the upstream default; values such as `0`, `00`, `-1`, or
  `1x` are rejected.
- **A patch does not apply:** Verify every component commit and start with clean
  generated worktrees. Run `project-008-prepare.sh` to recreate the exact
  pinned state. Do not hand-edit an upstream checkout.
- **A repository commit is wrong:** Do not switch to a branch or tag. Rerun the
  preparer so the immutable commit in the manifest is fetched and verified.
- **Optional GDB features are reported missing:** The successful build emitted
  several optional-feature warnings and still completed. Compare against
  `logs/project-007-build.log` before classifying a new failure.
- **`libatomic/configure` or cleanup prints command-not-found messages:** These
  appeared in the successful build. `libatomic.a` installed, final cleanup
  completed, and the overall command returned 0. They remain documented in
  `KNOWN_ISSUES.md`.

## Remaining limitations

- ARM64 is verified by this repository but is not documented as supported by
  official PS2DEV upstream documentation.
- Only Ubuntu 26.04 on the listed Raspberry Pi has completed this exact
  procedure.
- PS2SDK sample compilation and runtime validation have not begun.
- gsKit and Tyra have not been built or validated.
- The generated build trees and installed binaries are intentionally ignored
  by Git and must be reproduced locally.

See [BUILD_LOG.md](BUILD_LOG.md), [KNOWN_ISSUES.md](KNOWN_ISSUES.md), the
[upstream source inventory](docs/upstream-sources.md), and the preserved
Project 007 logs for complete evidence.
