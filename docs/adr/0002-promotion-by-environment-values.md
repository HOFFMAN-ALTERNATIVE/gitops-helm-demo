# 0002. Promote by editing environment values on one branch

Status: accepted
Date: 2026-10-17

## Context
A change has to move dev, then staging, then prod, with the difference between
environments visible in review. The repo is meant to show the pattern with as little
machinery as possible.

## Options
1. A branch per environment: promotion is a merge, but branches drift and diffs
   between environments become hard to read.
2. A repo per environment: strongest separation of access, and the most overhead for
   one chart and one team.
3. One `main` branch, one chart, and `environments/<env>/values.yaml` per environment.
   Promotion is a PR that changes the image tag or digest in the next environment's file.

## Decision
Option 3. Every environment difference is a values diff in one place, and a normal
change touches only those files.

## Consequences
- Promotion is a reviewed PR, so it has an author, a reviewer and a revert.
- All three Applications track the same revision. A change to the chart itself, or to
  a default that an environment does not override, reaches dev, staging and prod in
  the same sync. Sync waves order that rollout but do not hold prod back until staging
  is verified.
- Only values pinned per environment (image tag or digest) are truly staged.
- No image updater or automated promotion PRs. Add Argo CD Image Updater or a CI job
  when manual edits become the bottleneck.
