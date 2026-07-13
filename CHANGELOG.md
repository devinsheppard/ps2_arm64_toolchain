# Changelog

All notable project changes will be recorded here.

## Unreleased

### Added

- Project 001 repository foundation.
- Official-upstream source inventory and initial ARM64 feasibility assessment.
- Added a repository-local pinned checkout preparer that leaves upstream source unchanged and verifies each checkout with `git rev-parse HEAD`.
- Recorded the Project 003 stop condition: the IOP GCC pin resolves from an annotated tag object to a different commit SHA, so compilation did not begin.
- Normalized the IOP GCC pin from annotated tag object `dcd428...` to commit `5115c7...` and added commit-type validation before every nested checkout.
- Verified all normalized component and nested repository commits without modifying upstream source.
- Recorded the Project 004 native build: DVP and IOP binutils completed, then the kernel OOM-killed IOP GCC stage-1 `genautomata` under automatic four-way parallelism.
- Documented that the pinned official scripts do not expose a job-count override: they assign `getconf _NPROCESSORS_ONLN` after configuration overrides and explicitly pass that value to `-j`.
- Recorded the Project 005 stop condition without rerunning the known four-job OOM workload or changing system swap.
- Added initial repository-maintained DVP, IOP, and EE patches intended to support `PS2DEV_JOBS` while preserving the upstream default.
- Recorded the Project 006 stop condition: the first DVP patch hunk failed `git apply --check` because its context did not match the pinned source; no patch or build was applied.
- Added exact-source DVP, IOP, and EE patches under `patches/project-007/` with
  a validated `PS2DEV_JOBS` override and unchanged upstream default behavior.
- Added repository-local validation for patch scope, default and one-job
  behavior, and invalid job-count rejection.
- Completed the full pinned native ARM64 DVP, IOP, and EE toolchain build with
  `PS2DEV_JOBS=1`; verified AArch64 executables, versions, paths, and all exact
  nested source commits.
- Added a complete native ARM64 installation, resource-planning,
  troubleshooting, and verification guide based on the successful Project 007
  measurements.
- Added clean-workspace preparation and build wrappers that reproduce the exact
  pinned repository layout, explicit job-count patches, and successful DVP →
  IOP → EE build order.
- Added a read-only installation verifier and a 76-entry executable manifest;
  final verification passed all package, environment, resource, commit, patch,
  path, executable-format, and version checks without rebuilding.
- Added the approved Project 007 host record and the top-level immutable
  ps2toolchain commit to repository validation data.
