# Phase 8: AVOS Development GitOps Validation

## Status and scope

Development delivery is validated. Full Phase 8 sign-off remains pending.

Scope: account 396913735153, us-east-2, avos-dev-eks.
Ten business services and the suspended load generator are registered.
All twelve Applications, including the administrative root, passed fresh
Synced/Healthy reconciliation checks.

Shoppingassistantservice GitOps coverage, staging and production delivery,
and independent production approval enforcement remain pending.

## Delivery model

GitHub Actions tests, scans, builds, publishes, and signs images.
Image Updater is the sole automated image-reference writer.
Generated branches require PR checks and merge into protected main.
Protection applies to administrators. Required reviewer approvals are zero.

Development workloads automatically synchronize, prune, and self-heal.
The Terraform-owned administrative root synchronizes manually.

## Evidence

| Area | Evidence | Result |
|---|---|---|
| Frontend delivery | Workflow 39498450761; PR #76 | Signed image delivered |
| Updater coverage | PRs #77 and #78 | Eleven workload Applications |
| Promotion policy | PR #79 | Protected-main exception documented |
| Reconciliation | PR #80 | Automated sync and resource waves |
| Drift notification | PR #81 | Root drift email received |
| Self-healing | Frontend Service annotation changed | Restored at the same Git revision |
| Baseline | PR #82 | Known-good digest deployed |
| Candidate | Workflow 39903002330; PR #83 | Candidate deployed |
| Git rollback | PR #84 | Baseline runtime digest restored |
| ECR boundaries | Resource-specific IAM simulation | Approved reads allowed; writes denied |
| Kubernetes boundaries | Live authorization checks | Required access allowed; unrelated access denied |
| Fresh reconciliation | Twelve Applications refreshed | All Synced and Healthy |
| Cost control | CronJob inspection | Load generator suspended |
| Terraform convergence | Final plan | No changes |

## Rollback artifacts

Baseline:
`sha256:c3900f9a25928c3b227ac0dca09c425617e531a352c43d5518a6cfabe28aadfe`

Candidate:
`sha256:57dc5207a6d8659697621a959bc030f34c6df1da0704d48aa797acc0dce4eb5d`

Rollback merge:
`d3b4addf7597206a77cb99dc7298bb84c95a27d1`

The runtime artifact matched the baseline after the Git revert.
This controlled exercise did not establish a recovery-time objective.

## Least privilege

Cluster-wide controller grants were removed.
Argo CD registration is limited to argocd and avos-dev.
Image Updater uses a dedicated Git credential and scoped ECR reads.

Required discovery reads and development Deployment creation are allowed.
Development Secret reads, control-plane Service creation, out-of-scope
Deployment creation, and ClusterRoleBinding creation are denied.

Cache discovery reads were aligned across registered namespaces.
Secrets are excluded from resource discovery across cluster URLs.
Approved control-plane credential access remains separate.

Final correction: `834a814227d1cb66fa8b55f9b778422c8060c377`.

Image Updater reported eleven managed images, Ready=True, and Error=False
at 2026-10-25T05:21:06Z. Write-back status does not prove deployment.

## Remaining work

- Complete shoppingassistantservice GitOps coverage and dependencies.
- Complete staging and production overlays and delivery.
- Preserve ADR-001 isolation and promote the same approved digest.
- Enforce independent production approval and release controls.
- Validate protected-environment reconciliation and rollback.
- Separately exercise failed-sync notification delivery.
- Record the final CI credential-separation audit.

Inherited CloudHustler resources are not approved for reuse.
