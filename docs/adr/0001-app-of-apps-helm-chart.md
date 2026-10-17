# 0001. Generate per-environment Applications with an app-of-apps Helm chart

Status: accepted
Date: 2026-10-17

## Context
Three environments (dev, staging, prod) deploy the same chart into one cluster with
different values. Exactly one object should be applied by hand, everything else must
come from Git, and CI must be able to point the whole tree at the commit under test.

## Options
1. Three hand-written Application manifests: easy to read, but they drift apart, and
   pinning all of them to a commit in CI means editing three files.
2. An ApplicationSet with a list generator: built for this, and the natural choice for
   many clusters. Harder to unit-test, and per-environment sync policy needs templating
   inside the generator.
3. A small Helm chart (`argocd/apps`) that renders the AppProject and one Application
   per entry in `environments`, driven by a root Application.

## Decision
Option 3. The Applications are rendered by the same tool as the workload, so they get
helm-unittest coverage and kubeconform checks against the Argo CD CRDs, and one
`revision` value pins every child to the same commit.

## Consequences
- `kubectl apply -f argocd/root-app.yaml` is the only manual step.
- CI pins `revision` to the commit SHA, so the e2e drill tests exactly that commit.
- Per-environment sync policy (prune on or off) is plain values, covered by tests.
- Multi-cluster fan-out does not fit this shape. Move to an ApplicationSet with a
  cluster generator when a second cluster appears.
