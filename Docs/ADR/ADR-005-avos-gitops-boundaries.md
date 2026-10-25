# ADR-005: AVOS GitOps Ownership and Permission Boundaries

- Status: Accepted
- Date: 2026-10-25
- Scope: Development implementation and future promotion constraints

## Context

AVOS needs auditable delivery with separate CI and deployment ownership.
Protected main applies to administrators, preventing direct development
write-back. Default cluster-wide controller permissions exceed current needs.

## Decision

- GitHub Actions owns testing, scanning, image publication, and signing.
- Image Updater is the sole automated image-reference writer.
- Development image changes use generated branches and checked PRs.
- Argo CD reconciles merged Git state.
- Development workloads synchronize automatically; the root remains manual.
- Current mandatory reviewer approvals are zero.
- Independent production approval must be enforced before production delivery.
- Terraform owns controller installation, permissions, and bootstrap resources.
- Kubernetes delivery uses explicit Roles in argocd and avos-dev.
- Image Updater uses a dedicated Git credential and scoped ECR read access.
- Secrets are excluded from resource discovery across cluster URLs.
- Approved control-plane credential access remains separate.
- Rollback restores a known-good digest through reviewed Git changes.
- Future environments preserve ADR-001 account boundaries and artifact identity.
- Inherited CloudHustler resources are not reused.

## Consequences

Git remains the durable desired-state authority.
Namespace-specific writes reduce controller blast radius.
Cache discovery reads must be validated alongside delivery permissions.

Shoppingassistantservice GitOps coverage, staging and production delivery,
and independent production approvals remain pending.
Development validation does not constitute full Phase 8 sign-off.

## References

- [Validation report](../Phase-validation/Phase-8/PHASE-8-VALIDATION-REPORT.md)
- [Operations runbook](../../gitops/OPERATIONS-RUNBOOK.md)
- [Environment boundaries](ADR-001-environment-account-state-model.md)
