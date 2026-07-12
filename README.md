# PS2 ARM64 Toolchain

Infrastructure for investigating and, if feasible, producing a fully reproducible, ARM64-native PlayStation 2 development environment.

## Architectures

- Host: ARM64 (AArch64)
- Target: PlayStation 2 MIPS processors, principally the Emotion Engine and I/O Processor toolchains

## Goals

- Establish whether the official PS2DEV toolchain can be built natively on ARM64 hosts.
- Pin every upstream dependency to an exact commit for reproducibility.
- Preserve research, patches, build logs, failures, and validation evidence.
- Provide repeatable scripts and isolated build infrastructure only after feasibility is established.
- Keep all work self-contained in this repository.

## Current status

Project 001 provides the repository foundation and an official-source feasibility review. No toolchain has been installed or built, and no upstream repository has been cloned. ARM64 host support is still under investigation; successful native ARM64 operation has not been established.

See [the upstream source inventory](docs/upstream-sources.md), [BUILD_LOG.md](BUILD_LOG.md), and [KNOWN_ISSUES.md](KNOWN_ISSUES.md).
