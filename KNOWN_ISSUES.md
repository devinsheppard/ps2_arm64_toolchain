# Known Issues

## KI-001 — ARM64 host support is undocumented

- **Status:** Open
- **Affected:** ps2toolchain, ps2sdk, gsKit, Tyra
- **Evidence:** The reviewed official repository documentation does not name ARM64/AArch64 as a supported host.
- **Impact:** A native ARM64 build cannot be claimed supported without validation.

## KI-002 — Toolchain host portability is unverified

- **Status:** Open
- **Affected:** ps2toolchain and its binutils, GCC, newlib, and library inputs
- **Impact:** Old build-system code or PS2-specific patches may contain x86 assumptions or fail on ARM64.
- **Next investigation:** Inspect exact upstream pins and build scripts, then test without attempting ad hoc fixes.

## KI-003 — Downstream validation depends on a working cross-toolchain

- **Status:** Open
- **Affected:** ps2sdk, gsKit, Tyra
- **Impact:** Their native-host feasibility cannot be separated completely from ps2toolchain feasibility.

## KI-004 — Tyra's documented workflow is container-centric

- **Status:** Open
- **Affected:** Tyra
- **Evidence:** Official installation instructions specify Docker, PowerShell, VS Code, a prebuilt `h4570/tyra` image, and PCSX2.
- **Impact:** The documented method does not establish an ARM64-native toolchain or emulator path.

No issue above is a confirmed build failure because Project 001 performed no builds.
