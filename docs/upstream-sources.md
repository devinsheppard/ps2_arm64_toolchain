# Official Upstream Sources

Research captured 2026-07-12. Only project-owned GitHub repositories, release pages, and documentation contained in those repositories were used. “Current” values are a time-stamped research snapshot; future build milestones must use exact commit pins rather than branches or floating releases.

## ps2toolchain

- **Repository:** https://github.com/ps2dev/ps2toolchain
- **Current release:** `2018-10-19` (latest GitHub release; the release notes state releases are not expected regularly)
- **Current default branch:** `master`
- **Recommended build method:** Install the documented host prerequisites, set `PS2DEV`, `PS2SDK`, and `PATH`, then run `./toolchain.sh`. The script builds the DVP, IOP, and EE toolchains.
- **Documented host requirements:** gcc or clang, make, patch, git, texinfo, flex, bison, GSL, GMP, MPFR, MPC, and gettext; write permission to a `PS2DEV` path without spaces or special characters.
- **Known ARM64 issues:** None documented in the official README or release page. ARM64 is also not identified there as supported or tested.
- **Official references:** [repository and README](https://github.com/ps2dev/ps2toolchain), [releases](https://github.com/ps2dev/ps2toolchain/releases)

## ps2sdk

- **Repository:** https://github.com/ps2dev/ps2sdk
- **Current release:** No GitHub releases. The repository exposes tags, but none is designated as a current release.
- **Current default branch:** `master`
- **Recommended build method:** Install through ps2toolchain, whose official README says it also installs PS2SDK. For a source-tree build, the repository provides a top-level Makefile and dependency-download script, but its README does not provide a standalone host installation recipe.
- **Documented host requirements:** A functioning PS2DEV cross-toolchain and the environment described by ps2toolchain are implicit prerequisites. No separate host architecture or complete host package list is documented in the PS2SDK README.
- **Known ARM64 issues:** None documented in the official README or release page. ARM64 is not identified as supported or tested.
- **Official references:** [repository and README](https://github.com/ps2dev/ps2sdk), [releases](https://github.com/ps2dev/ps2sdk/releases)

## gsKit

- **Repository:** https://github.com/ps2dev/gsKit
- **Current release:** No GitHub releases. The repository exposes tags, but none is designated as a current release.
- **Current default branch:** `master`
- **Recommended build method:** Install PS2Toolchain (which also installs PS2SDK), set `GSKIT=$PS2DEV/gsKit`, then run `make && make install`. CMake is listed for building examples, followed by `make all`.
- **Documented host requirements:** PS2Toolchain, PS2SDK, the `PS2DEV`/`GSKIT` environment, Make, and CMake for examples. No host CPU architecture is specified.
- **Known ARM64 issues:** None documented in the official README or release page. ARM64 is not identified as supported or tested.
- **Official references:** [repository and README](https://github.com/ps2dev/gsKit), [releases](https://github.com/ps2dev/gsKit/releases)

## Tyra

- **Repository:** https://github.com/h4570/tyra
- **Current release:** `v2.7.3` (GitHub latest release)
- **Current default branch:** `master`
- **Recommended build method:** Follow the official installation tutorial: Git, VS Code, Docker with PowerShell as the default terminal, configured PCSX2, the prebuilt `h4570/tyra` image, repository/assets setup, and VS Code build tasks.
- **Documented host requirements:** Git, VS Code, Docker, PowerShell as the default terminal, configured PCSX2, an IntelliSense package, and release assets. The instructions describe a Windows-oriented configuration path and do not name a host CPU architecture.
- **Known ARM64 issues:** None explicitly documented in the official README, installation tutorial, or release page. The documented prebuilt image and PCSX2 workflow do not state ARM64 compatibility, so native ARM64 support remains unverified.
- **Official references:** [repository and README](https://github.com/h4570/tyra), [installation tutorial](https://github.com/h4570/tyra/tree/master/docs/install), [releases](https://github.com/h4570/tyra/releases)

## Feasibility classification

| Project | Official ARM64 support | Official known ARM64 failure | Project 001 assessment |
| --- | --- | --- | --- |
| ps2toolchain | Not documented | None found | Unofficial but plausibly feasible; requires controlled testing |
| ps2sdk | Not documented | None found | Feasibility depends on a working ARM64-hosted cross-toolchain |
| gsKit | Not documented | None found | Likely host-neutral after toolchain availability, but unverified |
| Tyra | Not documented | None found | Container-centric official path; native ARM64 status unverified |

The assessments are inferences from build methods and dependency relationships, not official support claims and not build results.
