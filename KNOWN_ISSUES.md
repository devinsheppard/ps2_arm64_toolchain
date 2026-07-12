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

## KI-005 — Immutable commit override is incompatible with nested clone command

- **Status:** Resolved in Project 004 by repository-local prepopulation
- **Affected:** DVP toolchain nested binutils checkout; potentially other nested checkout scripts with the same pattern
- **Classification:** Configuration error
- **Evidence:** With DVP binutils pinned to commit `3eb45ea37f0efd498d1de3cf9562de07197aefa8`, the official script ran `git clone -b` and Git reported `Remote branch ... not found in upstream origin`. The complete output is in `logs/project-002-build.log`.
- **Impact:** The official documented build workflow cannot consume the exact immutable nested commit through its clone path. The build stopped before any ARM64 compilation test.
- **Upstream base:** `ps2dev/ps2toolchain-dvp` commit `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a` and `ps2dev/binutils-gdb` commit `3eb45ea37f0efd498d1de3cf9562de07197aefa8`.
- **Changed behavior:** None. Upstream source was not modified and no patch was attempted.
- **Validation status:** Reproduced once on Ubuntu 26.04 ARM64; command exited 1. ARM64 feasibility remains unverified.

## KI-006 — IOP GCC pin identifies an annotated tag object, not a commit

- **Status:** Resolved in Project 004
- **Affected:** `validation/project-002-pins.sh`, IOP GCC checkout
- **Classification:** Reproducibility issue
- **Evidence:** Fetching object `dcd428f94ffb464418f996ffb70dfa398f5caa3f` and checking out `FETCH_HEAD` produced `git rev-parse HEAD` value `5115c7e447fc07457443df874bf57840e8316d5f`. The equality check exited 1; see `logs/project-003-preclone.log`.
- **Impact:** The manifest does not yet contain an exact commit for every dependency, so the official build retry cannot begin reproducibly.
- **Compilation status:** Not begun.
- **ARM64 relevance:** None apparent; this is Git object-type handling, not host compilation.
- **Recommended next objective:** Resolve all pins as commit objects, correct every annotated-tag object pin, rerun checkout verification, and only then retry the official build.

## KI-007 — IOP GCC stage 1 exceeds available memory at automatic parallelism

- **Status:** Confirmed in Project 004; open
- **Affected:** IOP GCC 15.2.0 stage 1, `s-automata` / `genautomata`
- **Classification:** Configuration error (host resource exhaustion)
- **Exact command:** `build/genautomata ../../gcc/common.md ../../gcc/config/mips/mips.md insn-conditions.md > tmp-automata.cc`, launched under upstream `make --quiet -j 4 all`
- **Exact error:** PID 200237 was killed; Make reported `Makefile:2786: s-automata` error 137 and propagated failure through `all-gcc`, `002-gcc-stage1.sh`, and `002-iop.sh`.
- **OOM evidence:** The kernel journal explicitly records a global OOM kill of `genautomata` with about 1.61 GiB anonymous RSS. The host has 3.7 GiB RAM and 1.0 GiB swap, which was effectively exhausted.
- **Progress before failure:** The full DVP toolchain components and IOP binutils/GDB built and installed. IOP GCC configured for an AArch64 host and began stage-1 compilation. EE did not start.
- **ARM64 relevance:** No ARM64-specific error was observed; the kernel killed a memory-intensive host process.
- **Recommended next objective:** Establish a reproducible lower-parallelism or higher-memory build environment and retry without source patches.
