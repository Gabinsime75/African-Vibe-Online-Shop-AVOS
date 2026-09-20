# AVOS Phase 0 Evidence Index

## Purpose

This index connects Phase 0 conclusions to reproducible repository evidence without storing secrets, Terraform state, credentials, or kubeconfig files.

| Evidence ID | Evidence | Location or command | Supports |
|---|---|---|---|
| EVD-001 | Imported baseline commit | `git rev-parse avos-baseline-v1^{}` | Exact baseline identity. |
| EVD-002 | Baseline tag | `git tag --list avos-baseline-v1` | Recoverable pre-implementation reference. |
| EVD-003 | Source component list | `find src -mindepth 1 -maxdepth 1 -type d` | Eleven services plus load generator. |
| EVD-004 | CI workflow list | `find .github/workflows -maxdepth 1 -type f` | Seven covered services and reusable workflow. |
| EVD-005 | GitOps file list | `find gitops -type f` | Existing bases, overlays, and Argo CD applications. |
| EVD-006 | Terraform root list | `find terraform -maxdepth 3 -type d` | Existing AWS and platform infrastructure foundations. |
| EVD-007 | Terraform module count | `find terraform/modules -mindepth 1 -maxdepth 1 -type d` | Forty inherited reusable module directories. |
| EVD-008 | Tracked unsafe artifacts | `git ls-files` filtered for state, backup, binary, key, and credential patterns | Phase 1 cleanup candidates. |
| EVD-009 | Legacy reference scan | `rg -l -i` for inherited brand and provider terms | Rebranding and AWS migration scope. |
| EVD-010 | Approved gRPC map | `docs/architecture/avos-grpc-service-dependency-map.*` | Internal service dependency target. |
| EVD-011 | Approved project architecture | `docs/architecture/avos-project-architecture.*` | Target AWS, platform, operations, analytics, and AIOps architecture. |
| EVD-012 | Implementation roadmap | `docs/roadmap/AVOS-IMPLEMENTATION-ROADMAP.md` | Phase ordering, validation, cleanup, and sign-off requirements. |
| EVD-013 | Phase 0 inventory | `docs/baseline/PHASE-0-BASELINE-INVENTORY.md` | Consolidated repository baseline. |
| EVD-014 | Gap register | `docs/baseline/PHASE-0-GAP-REGISTER.md` | Keep/Modify/Replace/Add/Remove decisions. |
| EVD-015 | Capability status | `docs/baseline/PHASE-0-CAPABILITY-STATUS.md` | Honest implementation and deployment status. |
| EVD-016 | Architecture decisions | `docs/adr/` | Approved technical and ownership decisions. |

## Evidence handling rules

- Evidence must be reproducible from reviewed code or dated read-only commands.
- Secrets, state files, private keys, tokens, kubeconfig files, and unredacted account identifiers must not be copied into documentation.
- Screenshots supplement command output but do not replace repeatable validation.
- A capability moves to **Currently deployed** only after runtime evidence is captured in its owning phase.
- Evidence files must identify the commit, environment, date, command, expected result, and actual result.
