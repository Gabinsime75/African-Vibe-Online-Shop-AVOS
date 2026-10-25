# AVOS GitOps Operations Runbook

## Ownership

Terraform owns controller Helm releases, permissions, bootstrap project,
and the administrative root Application.
Git under gitops owns workload desired state and root-managed resources.
Change ApplicationSet-generated settings in the Git template.

Development is the only validated environment.
Future environments must preserve ADR-001 account isolation.

## Development promotion

1. Verify publication, scanning, signing, and artifact evidence.
2. Review the Image Updater branch and open a PR against main.
3. Pass required checks and merge under branch protection.
4. Verify fresh reconciliation, rollout, readiness, and runtime artifact.
5. Leave unrelated updater branches unmerged.

Image Updater is the sole automated image-reference writer.
An updater status message does not prove a change was merged or deployed.
Current mandatory reviewer approvals are zero.

## Administrative root

The root Application requires manual synchronization.
Synchronize to the reviewed merge revision.
Check the operation's exact revision before accepting Succeeded,
then confirm fresh Synced/Healthy status.

Terraform controller changes require a reviewed plan and apply.
Root synchronization does not apply Terraform configuration.

## Drift and failed synchronization

An OutOfSync email can indicate manual drift or a pending Git deployment.
Inspect the resource diff and Git revision before identifying the cause.

Development workload drift is subject to automatic self-healing.
Administrative root drift requires investigation and manual synchronization.
Failed-sync notification is configured but not separately exercised.

A Healthy workload can coexist with stale or Unknown synchronization status.
Verify fresh reconciledAt timestamps, cleared refresh annotations,
and absence of comparison errors before accepting recovery.

## Permissions and cache

Retain explicit namespace Roles and namespace-scoped cluster registration.
Keep discovery reads consistent across the registered namespaces.
Preserve namespace-specific write permissions.

Secrets are excluded from resource discovery across cluster URLs.
Separate control-plane settings and credential clients retain approved access.
GitOps delivery of Secret resources is outside the current development scope.

For forbidden operations, inspect the exact resource, verb, and namespace.
Update Terraform-owned permissions and verify allowed and denied access.
Do not restore wildcard cluster permissions to resolve cache errors.

## Git rollback

1. Select a verified known-good artifact digest.
2. Revert the isolated image-change commit on a branch.
3. Review the diff, open a PR, pass checks, and merge.
4. Verify fresh reconciliation to the rollback revision.
5. Verify rollout, Pod readiness, runtime digest, and application health.
6. Record the PRs, revisions, digests, and observations.

For mixed-purpose commits, prepare an isolated rollback PR.
Direct workload image patches and Argo CD history rollback do not replace
the Git rollback procedure.

## Terraform and cost control

Render pinned charts before permission changes.
Use Terraform plan/apply for Helm-managed configuration.
Refresh plans after merge and inspect their resource scope before applying.
Keep credentials and plan files out of Git.

Renew expired AWS sessions with:
`aws sso login --profile avos-admin`.

Keep the load generator suspended except during approved bounded tests.
Use current AVOS resources; inherited resources are not approved for reuse.

## References

- [Promotion policy](ENVIRONMENT-PROMOTION.md)
- [Reconciliation policy](RECONCILIATION-POLICY.md)
- [Validation report](../Docs/Phase-validation/Phase-8/PHASE-8-VALIDATION-REPORT.md)
