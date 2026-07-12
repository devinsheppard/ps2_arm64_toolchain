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
