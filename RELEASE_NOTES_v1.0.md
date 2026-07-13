# Native ARM64 PS2 Toolchain Version 1.0

Version 1.0 is the first public release of a reproducible, repository-local
workflow for building the official PS2DEV DVP, IOP, and EE toolchains natively
on ARM64 Ubuntu.

## Milestone history

- **Project 001 — Feasibility review:** Established the official upstream
  source inventory and found no documented ARM64 support statement or known
  definitive ARM64 failure.
- **Project 002 — First native attempt:** Mapped official requirements to
  Ubuntu packages and exposed the incompatibility between immutable commit
  pins and upstream `git clone -b` commands.
- **Project 003 — Pinned preclone workflow:** Preserved upstream source while
  prepopulating the paths expected by official scripts. This revealed that the
  original IOP GCC pin named an annotated tag object rather than a commit.
- **Project 004 — Commit normalization:** Peeled every Git object to an exact
  commit, verified all nested checkouts, and reached substantial native ARM64
  compilation. The four-job IOP GCC stage-1 build was killed by the kernel OOM
  killer.
- **Project 005 — Resource investigation:** Confirmed the official component
  scripts derive job count from `getconf _NPROCESSORS_ONLN`, explicitly pass it
  to `-j`, and expose no documented override.
- **Project 006 — First override patch:** Demonstrated the need to generate
  patches from the exact pinned source when the initial DVP patch context did
  not apply. No build ran and upstream worktrees remained unchanged.
- **Project 007 — Exact patches and successful build:** Generated and validated
  separate DVP, IOP, and EE `PS2DEV_JOBS` patches from the pinned sources. The
  full toolchain built successfully with one job and all installed tools were
  verified as native AArch64 executables or portable helper scripts.
- **Project 008 — Reproducible installation:** Added a complete installation
  guide, clean-workspace source preparation, a build wrapper, an exact
  executable manifest, and read-only finished-installation verification.

## Major engineering discoveries

1. The official toolchain can compile natively on ARM64 even though upstream
   documentation does not list ARM64 as supported.
2. A raw commit SHA cannot be supplied to the upstream `git clone -b` path.
   Precloning exact commits into expected directories preserves upstream logic
   and reproducibility.
3. Git tag object IDs and commit IDs are not interchangeable pins. Every
   immutable input must be validated as, or recursively resolved to, a commit.
4. The observed blocker was host memory pressure, not an ARM64 compiler defect.
   Four parallel jobs exceeded the verified system's resources.
5. An opt-in job override can be added without changing the official default:
   unset or empty `PS2DEV_JOBS` still uses `getconf`; a positive integer selects
   explicit parallelism; invalid values fail before compilation.

## Native ARM64 validation

The verified build environment was:

- Raspberry Pi 4 Model B Rev 1.2;
- Ubuntu 26.04 LTS (Resolute Raccoon), ARM64;
- Linux `7.0.0-1009-raspi`;
- 3.7 GiB usable RAM;
- 1.0 GiB configured swap;
- `PS2DEV_JOBS=1`.

The complete DVP → IOP → EE build finished in 9:21:11. GNU `time -v`
reported maximum RSS of 2,096,896 KiB. The process completed without OOM and
without a confirmed ARM64-specific failure.

Version 1.0 verifies:

- MASP 0.1.16 and OpenVCL 0.4.0;
- DVP GNU Binutils 2.45.1;
- IOP GNU Binutils 2.45.1 and GCC/G++ 15.2.0;
- EE GNU Binutils 2.45.1 and GCC/G++ 15.2.0;
- all 13 exact upstream repository commits;
- all three explicit job-count patches;
- the exact 76-entry installed executable inventory;
- repository-local paths and successful representative version execution.

The final Version 1.0 installation verifier completed with zero failures and
zero warnings. The toolchain was not rebuilt during release preparation.

## Repository capabilities

- Immutable official-upstream commit manifest.
- Exact component and nested repository preparation.
- Documented, validated DVP/IOP/EE job-count patches.
- Resource-controlled official component build wrapper.
- Complete Ubuntu package and environment instructions.
- Read-only host, repository, patch, binary, path, and version verification.
- Preserved successful and failed milestone transcripts.
- Evidence-based troubleshooting and known-issue classification.

## Current limitations

- ARM64 support remains undocumented by official PS2DEV upstream sources.
- Only the listed Raspberry Pi 4 and Ubuntu 26.04 environment has completed
  this exact workflow.
- The Project 008 convenience wrappers have not yet performed a second full
  build from a clean host; they reproduce the already successful commands and
  passed syntax and consistency review.
- PS2SDK sample compilation and runtime validation are out of scope.
- gsKit and Tyra have not been built or validated.
- No prebuilt binaries, generated build trees, containers, or Docker images are
  distributed.

## Future work

Recommended follow-on work, outside Version 1.0, is:

1. Execute the Version 1.0 convenience workflow on a second clean ARM64 host.
2. Validate PS2SDK and representative samples with the native toolchain.
3. Evaluate gsKit only after PS2SDK validation succeeds.
4. Evaluate Tyra and its container/emulator assumptions separately.
5. Test other ARM64 hardware, Ubuntu releases, memory sizes, and safe job counts
   without weakening immutable pins or historical evidence.
