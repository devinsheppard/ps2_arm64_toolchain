# Changelog

All notable project changes will be recorded here.

## Unreleased

### Added

- Project 001 repository foundation.
- Official-upstream source inventory and initial ARM64 feasibility assessment.
- Added a repository-local pinned checkout preparer that leaves upstream source unchanged and verifies each checkout with `git rev-parse HEAD`.
- Recorded the Project 003 stop condition: the IOP GCC pin resolves from an annotated tag object to a different commit SHA, so compilation did not begin.
