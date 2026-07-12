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
