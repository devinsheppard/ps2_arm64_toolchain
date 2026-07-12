# Agent Instructions

These rules apply to every future milestone and every file in this repository.

1. Make small, reviewable commits.
2. Preserve build logs, including failed command output and relevant environment details.
3. Never fabricate or imply a successful build that did not occur.
4. Stop immediately at a genuine failure. Record it before proposing or attempting a later fix authorized by the milestone.
5. Document every patch: purpose, upstream base commit, changed behavior, and validation status.
6. Never silently modify upstream projects. Keep changes as explicit patch files in `patches/`.
7. Pin every dependency to an exact immutable commit. Branch names and floating tags are not reproducible pins.
8. Never modify repositories or files outside this project.
9. Complete and validate one milestone before beginning another.
