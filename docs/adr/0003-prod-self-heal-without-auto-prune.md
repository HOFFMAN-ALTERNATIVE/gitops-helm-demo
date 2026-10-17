# 0003. Auto-sync and self-heal prod, but never auto-prune it

Status: accepted
Date: 2026-10-17

## Context
Git should be the only way to change prod, so manual drift must be reverted. Auto-sync
also means a bad commit reaches prod with no human in between. The most damaging bad
commit is one that removes resources, for example a broken template that renders to nothing.

## Options
1. Manual sync for prod: a human approves every change, and drift stays until someone
   notices it.
2. Full automation (sync, self-heal, prune) everywhere: simplest and consistent, and a
   template bug can delete production resources on its own.
3. Auto-sync and self-heal in prod, prune off. Dev and staging prune automatically.

## Decision
Option 3. Additions and edits flow automatically and drift is reverted, but deleting
anything in prod needs an explicit, reviewed sync.

## Consequences
- The CI drill scales the dev Deployment by hand and checks that self-heal reverts it.
  Prod uses the same `selfHeal: true` setting.
- Resources removed from Git linger in prod until someone prunes them. Argo CD shows
  the prod Application as OutOfSync with those resources marked for pruning.
- Edits still apply automatically. A bad value can break prod; the schema
  (`values.schema.json`), PDB and `maxUnavailable: 0` limit how badly.
- A test asserts that the prod Application renders with `prune: false`, so the setting
  cannot be flipped by accident.
