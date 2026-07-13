# Build Log

Build and validation records must be appended without rewriting prior results. A command that was not run must never be presented as successful.

## 2026-07-12 — Project 001 feasibility review

### Scope

Research only. No upstream repository was cloned, no package or toolchain was installed, no Docker image was created, and no build was attempted.

### Findings

- **Official ARM64 support:** Not established. The reviewed official documentation for ps2toolchain, ps2sdk, gsKit, and Tyra does not list ARM64/AArch64 as a supported host architecture.
- **Known ARM64 failure:** Not established by the reviewed official sources. They do not document a definitive ARM64 failure.
- **Technical feasibility:** Plausible but unofficial and unverified. ps2toolchain builds GNU cross-development components from source through shell scripts, while ps2sdk and gsKit use Make-based builds after the toolchain exists. These mechanisms are not inherently limited to x86 hosts, but that observation is an inference, not a successful test.
- **Tyra:** Downstream of the PS2 development environment. Its documented setup uses a prebuilt Docker image plus VS Code, PowerShell, and PCSX2; this does not demonstrate a native ARM64 build.

### Major obstacles

1. The upstream projects do not publish an ARM64 support statement or ARM64-native validation result.
2. The complete toolchain depends on pinned versions and patches for binutils, GCC, newlib, and related libraries; host-architecture assumptions may exist anywhere in that chain.
3. Upstream continuous-integration and Docker artifacts must be inspected in a later milestone to determine which host architectures are actually exercised.
4. ps2sdk and gsKit cannot be meaningfully validated until the cross-toolchain is available.
5. Tyra's recommended workflow relies on prebuilt container and emulator tooling whose ARM64 availability is not documented in the reviewed instructions.

### Conclusion

Native ARM64 support appears technically possible enough to justify a controlled build investigation, but it is not officially supported or demonstrated by this research. Status remains **unverified**.

## 2026-07-12 — Project 002 native toolchain attempt

### Host and prerequisites

- **Host:** Ubuntu 26.04 LTS (`resolute`), `arm64`; Linux `7.0.0-1009-raspi` on `aarch64`.
- **Official requirements mapped to Ubuntu packages:** `gcc`, `make`, `patch`, `git`, `texinfo`, `flex`, `bison`, `libgsl-dev`, `libgmp-dev`, `libmpfr-dev`, `libmpc-dev`, and `gettext`.
- **Package action:** No packages were installed. Every required package was already present; installed versions were queried with `dpkg-query` before the build.
- **Install prefix:** `/home/devin/ps2_arm64_toolchain/build/ps2dev`.

### Immutable upstream inputs

- `ps2dev/ps2toolchain`: `6d63befdde76fd695435d16f246a3bde72a8c096`
- `ps2dev/ps2toolchain-dvp`: `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`
- `ps2dev/ps2toolchain-iop`: `8129f3ab5f6beb63e0ec1ed3627ef9b985750729`
- `ps2dev/ps2toolchain-ee`: `480a5f31c644107ceddcdadf6ee5502fb2cd14ff`
- Nested repository pins are recorded in `validation/project-002-pins.sh`. The file uses the official `PS2DEV_CONFIG_OVERRIDE` interface; upstream source was not modified.

### Command and result

The documented top-level command `./toolchain.sh` was run from the pinned ps2toolchain checkout with `PS2DEV`, `PS2SDK`, `PATH`, and `PS2DEV_CONFIG_OVERRIDE` set. The complete terminal transcript is preserved in `logs/project-002-build.log`; clone transcripts are preserved in the other `logs/project-002-clone*.log` files.

The command exited with status 1 at the first build step:

```text
Cloning into 'binutils-gdb'...
fatal: Remote branch 3eb45ea37f0efd498d1de3cf9562de07197aefa8 not found in upstream origin
../scripts/001-binutils.sh: Failed.
../scripts/001-dvp.sh: Failed.
```

### Classification and validation status

- **Classification:** Configuration error. The official DVP nested-source script passes its configured ref to `git clone -b`. The immutable binutils commit required by this repository is not a branch name, so clone rejects it before configuration or compilation begins.
- **ARM64 finding:** Inconclusive. No compiler source was configured or compiled, so this failure neither demonstrates nor disproves ARM64 support.
- **Validation:** Failed, exactly as recorded above. No installed binaries or versions were available to verify.
- **Stop condition:** Work stopped immediately. IOP, EE, PS2SDK, gsKit, and Tyra were not built, and no speculative patch was attempted.

## 2026-07-12 — Project 003 pinned checkout preparation

### Upstream script inspection

At the pinned component commits, the nested source scripts derive `REPO_FOLDER` from the repository URL and use this new-directory command:

```text
git clone --depth 1 -b "$REPO_REF" "$REPO_URL" "$REPO_FOLDER"
```

The command occurs at line 26 of DVP `scripts/001-binutils.sh`, `scripts/002-masp.sh`, and `scripts/003-openvcl.sh`; IOP `scripts/001-binutils.sh` and `scripts/002-gcc-stage1.sh`; and EE `scripts/001-binutils.sh` through `scripts/006-gcc-stage2.sh` wherever a repository is fetched. The top-level `ps2toolchain` component scripts `scripts/001-dvp.sh`, `scripts/002-iop.sh`, and `scripts/003-ee.sh` use the same command at line 26.

Each script has an existing-directory path that runs `git fetch origin "$REPO_REF" --depth=1` and checks out the fetched object. This made repository-local prepopulation practical without changing upstream source.

### Repository-local workflow

`scripts/project-003-preclone.sh` was created to initialize each exact expected directory under `build/ps2toolchain/build`, fetch only its configured immutable object ID, detach at `FETCH_HEAD`, and require `git rev-parse HEAD` to equal the pin. The script uses `set -euo pipefail` and `set -x`; its complete transcript is `logs/project-003-preclone.log`. No upstream patch or source modification was made.

The following checkouts passed exact `HEAD` verification:

- DVP binutils: `3eb45ea37f0efd498d1de3cf9562de07197aefa8`
- DVP masp: `ddb4fa5fb1546e74662979a4e417217c27201c3f`
- DVP openvcl: `5d432985669f9ed2ecde7058a8d2faeb0396b2d4`
- IOP binutils: `48324fde1e284293dd3d570dba597cb644921c92`

### First genuine failure

- **Component:** IOP GCC source checkout.
- **Exact fetch command:** `git -C build/ps2toolchain/build/ps2toolchain-iop/build/gcc fetch origin dcd428f94ffb464418f996ffb70dfa398f5caa3f --depth=1`
- **Exact failing validation:** `test 5115c7e447fc07457443df874bf57840e8316d5f = dcd428f94ffb464418f996ffb70dfa398f5caa3f`
- **Error:** The check returned status 1. Fetching the stored object `dcd428...` and checking out `FETCH_HEAD` produced commit `5115c7...`, proving the stored value is an annotated tag object rather than the commit itself.
- **Classification:** Reproducibility issue in the Project 002 pin manifest.
- **Compilation begun:** No. The official `./toolchain.sh` retry was not started because pinned-source preparation did not validate.
- **ARM64-specific:** No. Git annotated-tag peeling is host-architecture independent.
- **Stop condition:** Work stopped immediately; the pin was not corrected and no further checkout or build command was attempted.
- **Recommended Project 004 objective:** Resolve every stored upstream object to a commit (`^{commit}` semantics), replace any tag-object pins with commit SHAs, validate all expected checkouts, then retry the unchanged official toolchain build.

## 2026-07-12 — Project 004 normalized pins and native build

### Pin normalization and validation

All 12 upstream objects were fetched from their official repositories and inspected with `git cat-file -t`; each was recursively resolved with `git rev-parse --verify 'FETCH_HEAD^{commit}'`. Eleven stored objects were already commits. The IOP GCC annotated tag object `dcd428f94ffb464418f996ffb70dfa398f5caa3f` resolved to commit `5115c7e447fc07457443df874bf57840e8316d5f`, which replaced the tag object in the manifest.

The complete object audit is preserved in `logs/project-004-pin-audit.log`. The normalized preclone run is preserved in `logs/project-004-preclone.log`; it exited 0 after all nine nested repositories were detached and verified at these commits:

- DVP binutils: `3eb45ea37f0efd498d1de3cf9562de07197aefa8`
- DVP masp: `ddb4fa5fb1546e74662979a4e417217c27201c3f`
- DVP openvcl: `5d432985669f9ed2ecde7058a8d2faeb0396b2d4`
- IOP binutils: `48324fde1e284293dd3d570dba597cb644921c92`
- IOP GCC: `5115c7e447fc07457443df874bf57840e8316d5f`
- EE binutils: `616e51fa6ed9d1e8f4bda7d0087fac30c5398aa9`
- EE GCC: `df77d03bc1bd5765b40de554918a5ff541202548`
- EE newlib: `58fb6406408a541e0c826f47487315b485d4db56`
- EE pthread-embedded: `b1746fd2b52d5aeafc1173761eb50e0958e8994b`

The component commits remained DVP `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`, IOP `8129f3ab5f6beb63e0ec1ed3627ef9b985750729`, and EE `480a5f31c644107ceddcdadf6ee5502fb2cd14ff`. Upstream source was not modified and no architecture patch was added.

### Official build progress

The official top-level `./toolchain.sh` was run with the normalized override, `PS2DEV=/home/devin/ps2_arm64_toolchain/build/ps2dev`, and the corresponding repository-local `PS2SDK`. Its complete transcript is `logs/project-004-build.log`.

Before failure, the ARM64 host successfully:

- configured, compiled, and installed DVP binutils;
- configured, compiled, and installed DVP masp and openVCL;
- configured, compiled, and installed IOP binutils, assembler, linker, and GDB;
- configured IOP GCC 15.2.0 as an `aarch64-unknown-linux-gnu` to `mipsel-none-elf` cross-compiler;
- began compiling IOP GCC stage 1 and generated multiple MIPS backend decision tables.

EE was not started. The full toolchain did not complete, so final binary/version validation was not performed.

### First genuine failure

- **Component:** IOP GCC 15.2.0, stage 1, GCC machine-description automaton generation (`s-automata`).
- **Upstream command:** `make --quiet -j "$PROC_NR" all`, with `PROC_NR=$(getconf _NPROCESSORS_ONLN)` resolving to 4.
- **Exact failed recipe command:** `build/genautomata ../../gcc/common.md ../../gcc/config/mips/mips.md insn-conditions.md > tmp-automata.cc`.
- **Exact fatal output:** `/bin/bash: line 2: 200237 Killed ...`; `make[2]: *** [Makefile:2786: s-automata] Error 137`, followed by `all-gcc`, stage, and component failures. The top-level transcript ended with `COMMAND_EXIT_CODE="1"`.
- **OOM determination:** Confirmed. The kernel journal reports a global OOM event at 07:15:05, identifies `genautomata` PID 200237, and records `Out of memory: Killed process 200237 (genautomata)` with approximately 1.61 GiB anonymous RSS. At post-failure inspection the 3.7 GiB host also had essentially all of its 1.0 GiB swap consumed.
- **Classification:** Configuration error: automatic four-way parallelism exceeded the host's available memory. The process was killed by the kernel rather than failing with a compiler diagnostic.
- **Compilation begun:** Yes. DVP and IOP binutils completed, and IOP GCC stage 1 was actively compiling/generating backend sources.
- **ARM64-specific:** No evidence. The failure is resource exhaustion; configuration and substantial ARM64-hosted compilation succeeded beforehand.
- **Stop condition:** No retry, parallelism change, memory change, patch, or later toolchain step was attempted.
- **Recommended Project 005 objective:** Define and document a reproducible resource-constrained build setting (lower job count and/or adequate memory/swap), then resume the same normalized official build and stop at its next genuine failure or success.

## 2026-07-12 — Project 005 resource-control investigation

### Official parallelism mechanism

The pinned official DVP, IOP, and EE component scripts were inspected without modification. Every compile script determines its job count internally with:

```text
PROC_NR=$(getconf _NPROCESSORS_ONLN)
```

and then invokes Make or CMake with an explicit `-j "$PROC_NR"`. In the failed IOP GCC stage-1 script, these are lines 55-56 and 100 of `scripts/002-gcc-stage1.sh` at upstream commit `8129f3ab5f6beb63e0ec1ed3627ef9b985750729`:

```text
PROC_NR=$(getconf _NPROCESSORS_ONLN)
make --quiet -j "$PROC_NR" all
```

The scripts source `PS2DEV_CONFIG_OVERRIDE` before assigning `PROC_NR`, so the supported override cannot set or preserve a job count. The official READMEs and configuration files expose no parallelism setting. An external `MAKEFLAGS=-j1` would be superseded by the explicit command-line `-j 4` and therefore is not the official mechanism used by these scripts.

### Affinity and swap findings

The host reports 4 from `getconf _NPROCESSORS_ONLN`. Restricting a read-only test command to one CPU with `taskset` changed `nproc` from 4 to 1 but left `getconf _NPROCESSORS_ONLN` at 4. CPU affinity therefore does not reduce the job count selected by this workflow.

The official upstream documentation reviewed by this project contains no swap sizing or swap-creation procedure. Creating or changing system swap would modify state outside this repository, which AGENTS.md prohibits. No swap change was requested or performed.

### Result and stop condition

- **Build action:** No build was rerun. With no supported one-job input, an otherwise identical retry would again select four jobs on the same memory-constrained host and would not satisfy Project 005's resource-control requirement.
- **Source action:** No upstream source, compiler logic, optimization flag, or generated tree was changed. No patch was created.
- **ARM64 finding:** Unchanged. Project 004 demonstrated substantial native ARM64 compilation and exposed only a confirmed OOM kill; Project 005 produced no new ARM64-specific failure.
- **Classification:** Configuration limitation in the official workflow: job count is hard-coded from online processor count and is not externally configurable through its documented override.
- **Recommended Project 006 objective:** Explicitly choose one of two reproducible paths: authorize a minimal repository-maintained patch that adds a job-count override to each upstream script while preserving the default behavior, or run the unchanged pinned workflow on a host with enough memory for its mandatory four-job build. Validate the chosen resource control before resuming the build.

## 2026-07-12 — Project 006 configurable parallelism patch attempt

### Scope and patch design

Inspection identified 11 direct parallelism assignments, not a shared function: DVP `scripts/001-binutils.sh`, `002-masp.sh`, and `003-openvcl.sh`; IOP `scripts/001-binutils.sh` and `002-gcc-stage1.sh`; and EE `scripts/001-binutils.sh` through `006-gcc-stage2.sh` where applicable. Each uses `PROC_NR=$(getconf _NPROCESSORS_ONLN)` and later supplies that value to `-j`.

Three repository-maintained patches were created for the exact component bases recorded in their headers. Their intended one-line behavior change was:

```text
PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}
```

This expression preserves the upstream `getconf` command when `PS2DEV_JOBS` is unset and selects the explicit value when it is set. No compiler source, build target, or optimization flag was included in the patches.

### First genuine failure

- **Component:** Patch application to `ps2dev/ps2toolchain-dvp` commit `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`.
- **Command:** `git -C build/ps2toolchain/build/ps2toolchain-dvp apply --check patches/ps2toolchain-dvp-ps2dev-jobs.patch` (absolute paths appear in the transcript).
- **Exact error:** `error: patch failed: scripts/001-binutils.sh:51` followed by `error: scripts/001-binutils.sh: patch does not apply`.
- **Cause:** The patch hunk's trailing context expected `for TARGET_ALIAS in "dvp"; do`, while the pinned upstream file uses `for TARGET in "dvp"; do` at line 57. The intended changed assignment itself is at line 54.
- **Changed behavior:** None. `git apply --check` failed before application; all three upstream component worktrees remained clean.
- **Validation status:** Failed for the first DVP hunk. IOP and EE patch application, default/override behavior validation, and the toolchain build were not attempted because AGENTS.md requires stopping at the first genuine failure.
- **OOM/ARM64 status:** No build ran, so no OOM event or ARM64-specific issue occurred in Project 006.
- **Recommended Project 007 objective:** Regenerate the minimal DVP, IOP, and EE patches directly against their exact pinned file contents, validate every patch with `git apply --check`, then verify unset and `PS2DEV_JOBS=1` job selection before resuming the resource-controlled build.

The complete failed application transcript is preserved in `logs/project-006-patch-apply.log`.

## 2026-07-12 — Project 007 pinned job-count patches and successful native build

### Exact pinned source inspection

The clean component worktrees were verified at DVP
`54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`, IOP
`8129f3ab5f6beb63e0ec1ed3627ef9b985750729`, and EE
`480a5f31c644107ceddcdadf6ee5502fb2cd14ff`. Eleven scripts independently
assigned `PROC_NR=$(getconf _NPROCESSORS_ONLN)` and passed it to existing
`make -j "$PROC_NR"` or `cmake --build ... -j "$PROC_NR"` commands:

- DVP: `scripts/001-binutils.sh` (assignment line 54, target loop line 57),
  `002-masp.sh` (line 34), and `003-openvcl.sh` (line 34).
- IOP: `scripts/001-binutils.sh` (line 55) and `002-gcc-stage1.sh` (line 56).
- EE: `scripts/001-binutils.sh` (line 53, target loop line 56),
  `002-gcc-stage1.sh` (line 55, loop line 58), `003-newlib.sh` (line 41,
  loop line 44), `004-newlib-nano.sh` (line 51, loop line 54),
  `005-pthread-embedded.sh` (line 40, loop line 43), and
  `006-gcc-stage2.sh` (line 58, loop line 61).

There was no literal `-j 4`; four jobs were derived from `getconf`. Every
parallel build command used `PROC_NR`. Upstream files were not modified during
inspection or patch generation.

### Patch design and validation

Three patches under `patches/project-007/` were generated from disposable
worktrees at the exact commits above. Each validates `PS2DEV_JOBS` after the
component configuration override, then changes only existing assignments to:

```text
PROC_NR=${PS2DEV_JOBS:-$(getconf _NPROCESSORS_ONLN)}
```

Unset and empty values therefore preserve the exact upstream `getconf`
behavior. Positive integers override it; non-numeric or all-zero values fail
with a clear error. Compiler flags, optimization, source, component order, and
paths are unchanged.

Ordered `git apply --check` validation passed for DVP, IOP, and EE against
clean pinned checkouts. After application to disposable worktrees,
`scripts/project-007-validate-job-patches.sh` verified intended diff scope,
all 11 assignments, the host default of four, `PS2DEV_JOBS=1`, and rejection
of `0`, `00`, `abc`, `1x`, and `-1`. Complete transcripts are preserved in
`logs/project-007-patch-check.log`, `logs/project-007-patch-apply.log`, and
`logs/project-007-behavior-validation.log`.

### Successful resource-controlled build

The official pinned DVP, IOP, and EE component workflows ran sequentially with
`PS2DEV_JOBS=1`, the existing immutable override, and repository-local
`PS2DEV`/`PS2SDK` paths. The complete transcript is
`logs/project-007-build.log`. It ended with all three
`COMPONENT_BUILD_COMPLETE` markers and exit status 0.

- **Elapsed time:** 9:21:11.
- **Maximum resident set:** 2,096,896 KiB (about 2.0 GiB).
- **OOM:** None. The timed command reported zero swaps and no process was
  killed; the Project 004 four-job failure did not recur.
- **ARM64 result:** No ARM64-specific failure appeared. DVP, IOP, and EE all
  configured and compiled natively from an `aarch64-unknown-linux-gnu` host.
- **Install scope:** All configured prefixes and verified executable realpaths
  are below `/home/devin/ps2_arm64_toolchain/build/`.

The build retained upstream warnings. Notable nonfatal output included missing
optional binutils/GDB features, GCC format-security warnings, machine-description
warnings, `libatomic/configure` command-not-found messages that did not stop its
successful archive/install, and cleanup-time missing `xgcc` messages after GCC
had already been removed by the clean sequence. The official workflow still
returned 0.

### Binary and commit verification

The final successful verification is preserved in
`logs/project-007-binary-validation-final.log`. Representative DVP, IOP, and
EE executables exist, run on AArch64, and report:

- MASP 0.1.16 and OpenVCL 0.4.0;
- DVP GNU assembler/binutils 2.45.1;
- IOP GNU binutils 2.45.1 and GCC/G++ 15.2.0;
- EE GNU binutils 2.45.1 and GCC/G++ 15.2.0.

All nine nested source checkouts matched the immutable commit manifest. An
earlier validation transcript, `logs/project-007-binary-validation.log`, is
also retained: it exited 1 because the validation command incorrectly assumed
a DVP `dvp-ld` executable, while the pinned DVP configuration intentionally
does not build `ld`. This did not rerun or invalidate the successful build.

Project 007 is complete. PS2SDK sample validation, gsKit, and Tyra were not
started.

## 2026-07-12 — Project 008 reproducible installation audit

### Verified installation inputs

Project 008 audited the successful Project 007 installation without rebuilding
or modifying compiler source. The approved host record in
`validation/project-007-host-info.txt` was compared with the preserved build
transcript and the live host:

- Raspberry Pi 4 Model B Rev 1.2, ARM64/AArch64;
- Ubuntu 26.04 LTS (Resolute Raccoon);
- Linux `7.0.0-1009-raspi`;
- 3.7 GiB usable RAM and 1.0 GiB configured swap;
- Project 007 duration 9:21:11 and maximum RSS 2,096,896 KiB;
- successful complete DVP, IOP, and EE build with `PS2DEV_JOBS=1` and no OOM.

The required Ubuntu package audit covered `gcc`, `make`, `patch`, `git`,
`wget`, `texinfo`, `flex`, `bison`, `libgsl-dev`, `libgmp-dev`, `libmpfr-dev`,
`libmpc-dev`, `gettext`, `cmake`, `file`, and `time`. All were installed on the
verified host; `bsdutils` supplies the transcript-capturing `script` command.
The cleaned on-disk footprint was approximately 6.3 GiB below
`build/ps2toolchain` and 436 MiB below `build/ps2dev`; Project 008 recommends at
least 10 GiB free before starting.

### Reproducible workflow

The immutable manifest now explicitly includes the top-level ps2toolchain
commit `6d63befdde76fd695435d16f246a3bde72a8c096` in addition to the three
component and nine nested repository pins. `scripts/project-008-prepare.sh`
creates all required repository levels, validates commit object types and exact
detached `HEAD` values, applies only the documented Project 007 patches, and
runs their behavior checks. This closes the previous assumption that component
repositories already existed.

`scripts/project-008-build.sh` preserves the successful Project 007 behavior:
repository-local `PS2DEV`/`PS2SDK`, the immutable configuration override,
positive `PS2DEV_JOBS`, and official DVP → IOP → EE component scripts. It does
not alter compiler source, flags, optimization, order, or paths. Both new
workflow scripts passed Bash syntax validation. They were not used to rebuild
the already successful installation in Project 008.

### Finished-installation verification

`scripts/project-008-verify-installation.sh` is read-only. It checks host
resources, all required packages and environment values, free disk, every
repository commit, exact patch application, all 76 entries in
`validation/project-008-expected-executables.txt`, repository-local realpaths,
native AArch64 ELF format or portable shell-helper format, and representative
version execution.

The initial transcript, `logs/project-008-verification-initial.log`, exited 1
because the first verifier revision incorrectly required four expected GDB
helper scripts (`gdb-add-index` and `gstack` for IOP and EE) to be AArch64 ELF
files. All actual compiled tools passed. The verifier was corrected to accept
executable, host-independent shell helpers; no toolchain file was changed.

The final transcript, `logs/project-008-verification.log`, ended with
`SUMMARY: failures=0 warnings=0`. It verified Binutils 2.45.1, GCC/G++ 15.2.0,
MASP 0.1.16, and OpenVCL 0.4.0. No rebuild was necessary.

### Remaining scope

The main installation guide now documents package installation, exact source
preparation, environment, resource expectations, build logging, validation,
swap guidance, and troubleshooting. Support remains verified only on the
recorded Raspberry Pi/Ubuntu host. Official upstream ARM64 support is still
undocumented; PS2SDK samples, gsKit, and Tyra remain unvalidated.
