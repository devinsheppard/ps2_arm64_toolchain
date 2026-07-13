# Known Issues

This file records both historical failures and current Version 1.0
limitations. Resolved entries remain for reproducibility and troubleshooting.

## KI-001 — ARM64 host support is undocumented

- **Status:** Open
- **Affected:** ps2toolchain, ps2sdk, gsKit, Tyra
- **Evidence:** The reviewed official repository documentation does not name ARM64/AArch64 as a supported host.
- **Impact:** Official ARM64 support cannot be claimed. This repository has
  independently validated one native ARM64 environment.

## KI-002 — Toolchain host portability is unverified

- **Status:** Resolved for ps2toolchain in Project 007; downstream remains unverified
- **Affected:** ps2toolchain and its binutils, GCC, newlib, and library inputs
- **Resolution:** The exact pinned DVP, IOP, and EE toolchain completed natively
  on Ubuntu 26.04 ARM64 with a validated one-job resource-control patch. No
  ARM64-specific failure appeared. This does not validate PS2SDK samples,
  gsKit, or Tyra.

## KI-003 — Downstream validation depends on a working cross-toolchain

- **Status:** Open
- **Affected:** ps2sdk, gsKit, Tyra
- **Impact:** Their native-host feasibility cannot be separated completely from ps2toolchain feasibility.

## KI-004 — Tyra's documented workflow is container-centric

- **Status:** Open
- **Affected:** Tyra
- **Evidence:** Official installation instructions specify Docker, PowerShell, VS Code, a prebuilt `h4570/tyra` image, and PCSX2.
- **Impact:** The documented method does not establish an ARM64-native toolchain or emulator path.

KI-001 through KI-004 originated in the Project 001 research milestone. Later
projects resolved toolchain feasibility but did not change upstream support
statements or validate downstream projects.

## KI-005 — Immutable commit override is incompatible with nested clone command

- **Status:** Resolved in Project 004 by repository-local prepopulation
- **Affected:** DVP toolchain nested binutils checkout; potentially other nested checkout scripts with the same pattern
- **Classification:** Configuration error
- **Evidence:** With DVP binutils pinned to commit `3eb45ea37f0efd498d1de3cf9562de07197aefa8`, the official script ran `git clone -b` and Git reported `Remote branch ... not found in upstream origin`. The complete output is in `logs/project-002-build.log`.
- **Historical impact:** The official documented clone path could not consume
  the exact immutable nested commit. The build stopped before ARM64 compilation.
- **Upstream base:** `ps2dev/ps2toolchain-dvp` commit `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a` and `ps2dev/binutils-gdb` commit `3eb45ea37f0efd498d1de3cf9562de07197aefa8`.
- **Changed behavior:** None. Upstream source was not modified and no patch was attempted.
- **Validation status:** Reproduced once in Project 002; resolved by the pinned
  preclone workflow before native ARM64 feasibility was later established.

## KI-006 — IOP GCC pin identifies an annotated tag object, not a commit

- **Status:** Resolved in Project 004
- **Affected:** `validation/project-002-pins.sh`, IOP GCC checkout
- **Classification:** Reproducibility issue
- **Evidence:** Fetching object `dcd428f94ffb464418f996ffb70dfa398f5caa3f` and checking out `FETCH_HEAD` produced `git rev-parse HEAD` value `5115c7e447fc07457443df874bf57840e8316d5f`. The equality check exited 1; see `logs/project-003-preclone.log`.
- **Historical impact:** The manifest did not contain an exact commit for every
  dependency, so the official build retry could not begin reproducibly.
- **Compilation status:** Not begun.
- **ARM64 relevance:** None apparent; this is Git object-type handling, not host compilation.
- **Resolution:** Project 004 replaced the annotated tag object with commit
  `5115c7e447fc07457443df874bf57840e8316d5f` and validates every object as a
  commit before checkout.

## KI-007 — IOP GCC stage 1 exceeds available memory at automatic parallelism

- **Status:** Resolved for this repository in Project 007
- **Affected:** IOP GCC 15.2.0 stage 1, `s-automata` / `genautomata`
- **Classification:** Configuration error (host resource exhaustion)
- **Exact command:** `build/genautomata ../../gcc/common.md ../../gcc/config/mips/mips.md insn-conditions.md > tmp-automata.cc`, launched under upstream `make --quiet -j 4 all`
- **Exact error:** PID 200237 was killed; Make reported `Makefile:2786: s-automata` error 137 and propagated failure through `all-gcc`, `002-gcc-stage1.sh`, and `002-iop.sh`.
- **OOM evidence:** The kernel journal explicitly records a global OOM kill of `genautomata` with about 1.61 GiB anonymous RSS. The host has 3.7 GiB RAM and 1.0 GiB swap, which was effectively exhausted.
- **Progress before failure:** The full DVP toolchain components and IOP binutils/GDB built and installed. IOP GCC configured for an AArch64 host and began stage-1 compilation. EE did not start.
- **ARM64 relevance:** No ARM64-specific error was observed; the kernel killed a memory-intensive host process.
- **Resolution:** The validated Project 007 patches allowed `PS2DEV_JOBS=1`.
  The complete DVP, IOP, and EE toolchain built in 9:21:11 with peak RSS of
  2,096,896 KiB and no OOM kill.

## KI-008 — Official scripts do not expose a build job-count override

- **Status:** Resolved for this repository in Project 007
- **Affected:** Pinned DVP, IOP, and EE build scripts
- **Classification:** Configuration limitation
- **Evidence:** Each compile script assigns `PROC_NR=$(getconf _NPROCESSORS_ONLN)` after sourcing `PS2DEV_CONFIG_OVERRIDE` and passes an explicit `-j "$PROC_NR"`. The official READMEs/configuration expose no alternative. On this host, `getconf` remains 4 even when a command is restricted to one CPU.
- **Historical impact:** A documented, otherwise identical one-job retry was
  unavailable. Repeating the workflow retained the four-job setting that
  triggered KI-007.
- **Swap:** Official documentation provides no swap procedure, and repository rules prohibit modifying system state outside the project. No swap was changed.
- **ARM64 relevance:** None established; this concerns host resource control rather than generated code or host instruction support.
- **Resolution:** Exact-source patches under `patches/project-007/` add an
  opt-in, validated `PS2DEV_JOBS` setting while preserving the upstream default
  when unset or empty.

## KI-009 — Initial configurable-parallelism patch has mismatched DVP context

- **Status:** Resolved in Project 007
- **Affected:** The removed legacy Project 006 DVP patch, first hunk for DVP
  `scripts/001-binutils.sh`
- **Classification:** Patch configuration error
- **Upstream base:** `ps2dev/ps2toolchain-dvp` commit `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`
- **Evidence:** `git apply --check` reported `patch failed: scripts/001-binutils.sh:51`. The hunk expected `for TARGET_ALIAS in "dvp"; do`; the pinned file contains `for TARGET in "dvp"; do`.
- **Changed behavior:** None; the check failed before application and all upstream worktrees stayed clean.
- **Validation:** DVP failed at the first hunk. IOP and EE patches and both job-count modes remain unvalidated because work stopped immediately.
- **ARM64 relevance:** None; no build was run.
- **Resolution:** Replacement patches were generated from exact detached pinned
  worktrees. DVP, IOP, and EE all passed `git apply --check`, behavior
  validation, and the complete one-job build. The invalid legacy patches and
  unused helper were removed during Version 1.0 preparation; their log remains.

## KI-010 — Successful build emits nonfatal libatomic and cleanup diagnostics

- **Status:** Observed in Project 007; nonblocking
- **Affected:** EE GCC 15.2.0 stage 2 at
  `df77d03bc1bd5765b40de554918a5ff541202548`
- **Evidence:** `libatomic/configure` printed `[test: command not found` and
  `1: command not found`; the final clean sequence printed missing `xgcc`
  messages after cleaning GCC. The complete evidence is in
  `logs/project-007-build.log`.
- **Impact:** None observed. `libatomic.a` was compiled, archived, ranlib'd,
  and installed. The EE component and complete timed build returned 0, and
  final binary validation passed.
- **ARM64 relevance:** None established. There was no host-architecture
  diagnostic or failure.

## KI-011 — Reproducibility is verified on one ARM64 platform only

- **Status:** Open limitation
- **Verified platform:** Raspberry Pi 4 Model B Rev 1.2, Ubuntu 26.04 LTS,
  Linux `7.0.0-1009-raspi`, 3.7 GiB usable RAM, and 1.0 GiB swap.
- **Evidence:** Project 007 completed in 9:21:11 with peak RSS of 2,096,896 KiB
  and no OOM using `PS2DEV_JOBS=1`; Project 008's finished-installation
  verification passed with zero failures and warnings.
- **Impact:** Other ARM64 hardware, kernels, Ubuntu releases, and resource
  profiles have not completed this exact procedure and must not be presented
  as verified.

## KI-012 — Project 008 clean-system wrappers have not performed a second build

- **Status:** Open validation limitation
- **Affected:** `scripts/project-008-prepare.sh` and
  `scripts/project-008-build.sh`
- **Evidence:** Both scripts passed Bash syntax and repository consistency
  review. Their exact pins, explicit patches, environment, and component order
  reproduce the successful Project 007 commands. Project 008 intentionally did
  not rerun the nine-hour build.
- **Impact:** The existing installation passed complete read-only validation,
  but a second clean-host end-to-end execution of the new convenience wrappers
  has not yet been recorded.
- **ARM64 relevance:** None; this is a validation-coverage limitation.

## KI-013 — Initial Project 008 verifier rejected portable GDB helper scripts

- **Status:** Resolved in Project 008
- **Evidence:** The first run treated IOP/EE `gdb-add-index` and `gstack` as
  failures because they are executable shell scripts instead of AArch64 ELF
  binaries. See `logs/project-008-verification-initial.log`.
- **Resolution:** The verifier now accepts either native AArch64 ELF tools or
  executable host-independent shell helpers. The final verification reported
  zero failures and warnings; no installed toolchain file changed.

## KI-014 — Project 008 preparer initially lacked its executable file mode

- **Status:** Resolved in Project 009
- **Evidence:** Release interface validation returned `Permission denied` when
  `scripts/project-008-prepare.sh` attempted to invoke
  `scripts/project-003-preclone.sh`; the latter was tracked as mode `100644`.
- **Resolution:** The preparer dependency is now tracked as executable. Bash
  syntax, help, and invalid-argument validation passed afterward. The final
  installation verifier reported zero failures and warnings.
- **Impact:** This was a repository packaging issue only. No compiler source,
  installed toolchain file, or successful Project 007 build result changed.
