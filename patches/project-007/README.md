# Project 007 job-count patches

## Purpose and behavior

These patches add the opt-in `PS2DEV_JOBS` resource-control setting required to
build the pinned toolchain on the 3.7 GiB ARM64 host. An unset or empty value
retains the upstream `getconf _NPROCESSORS_ONLN` result. A positive integer is
used by every existing `-j "$PROC_NR"` command. Non-numeric and all-zero values
exit with `ERROR: PS2DEV_JOBS must be a positive integer.`

The patches do not change compiler flags, optimization, component order,
repository pins, or installation paths. Validation occurs in the component
configuration file after the supported `PS2DEV_CONFIG_OVERRIDE` is sourced, so
an override file and the process environment receive identical validation.

## Upstream bases

- `ps2dev/ps2toolchain-dvp` at `54d25004c9d9d0d10d5f320703a8fe7c6ddb684a`
- `ps2dev/ps2toolchain-iop` at `8129f3ab5f6beb63e0ec1ed3627ef9b985750729`
- `ps2dev/ps2toolchain-ee` at `480a5f31c644107ceddcdadf6ee5502fb2cd14ff`

Each patch was generated from a detached disposable worktree at its listed
commit. The persistent pinned upstream worktrees were not edited while the
patches were created.

## Validation status

All three patches passed `git apply --check` against clean pinned checkouts.
After application to disposable worktrees, the repository validation script
confirmed the intended file scope, no whitespace errors, the unchanged default
job count, a one-job override, and rejection of `0`, `00`, `abc`, `1x`, and
`-1`. The complete toolchain subsequently built successfully with
`PS2DEV_JOBS=1` on Ubuntu 26.04 ARM64.

Transcripts are in `logs/project-007-patch-check.log`,
`logs/project-007-patch-apply.log`,
`logs/project-007-behavior-validation.log`, and
`logs/project-007-build.log`.
