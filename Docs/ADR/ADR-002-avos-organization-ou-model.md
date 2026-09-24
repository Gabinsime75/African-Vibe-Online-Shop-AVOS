# ADR-002: AVOS Organization and OU Model

## Status

Accepted

## Context

AVOS requires an AWS Organizations hierarchy that separates security,
infrastructure, workloads, experimentation, policy testing, and suspended
accounts.

The existing organization has two accounts directly under its root and no
custom OUs or SCPs. One existing account is not confirmed as part of AVOS and
must remain untouched.

The current management account temporarily contains AVOS development resources.
AWS management accounts cannot be moved into an OU.

## Decision

AVOS will use the following target hierarchy:

```text
Root
├── Security
├── Infrastructure
├── Workloads
│   ├── Development
│   ├── Staging
│   └── Production
├── Sandbox
├── Policy-Staging
└── Suspended

## Implementation constraint

This hierarchy is approved and frozen for the Phase 3 implementation.

Terraform must create exactly six top-level OUs and exactly three nested workload
OUs. The implementation must not rename, add, remove, or reorganize these OUs
without explicit approval and a superseding architecture decision record.

No existing AWS account will be moved by the initial organization deployment.