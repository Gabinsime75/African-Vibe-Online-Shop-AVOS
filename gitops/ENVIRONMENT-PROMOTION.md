# AVOS Environment Promotion

## Ownership

GitHub Actions builds, tests, scans, publishes, and signs container images.
Argo CD Image Updater is the sole automated image-reference writer.
Argo CD reconciles merged Git configuration into Kubernetes.

## Development promotion

Development runs in the existing sandbox account in us-east-2.
Image Updater writes service-overlay changes to generated branches.
A pull request targets main, passes the required checks, and is merged.
Applications currently synchronize manually; step 8.9 defines sync policy.

Main requires pull requests and up-to-date status checks, including for
administrators. Its current required approving-review count is zero.
Do not describe this configuration as enforcing independent approval.

Because development shares protected main, direct updater pushes to main
are not enabled. This is the protected-branch exception to roadmap step 8.8.
Image Updater writes Git branches; PR creation currently uses GitHub CLI.

## Staging and production promotion

ADR-001 requires separate target accounts and environment-specific roles
and state. Do not deploy these environments into the development cluster.

Promote the same approved image digest through an environment-specific PR.
Do not rebuild an image as part of promotion. Record the source image,
digest, verification evidence, destination, and rollback digest in the PR.

Before live promotion, establish the destination account and cluster,
environment overlay, restricted Argo CD destination, and approval controls.
Production must enforce independent approval before live releases.
These destination controls and cross-environment delivery remain pending.

## Validated development evidence

Frontend workflow 39498450761 built, scanned, published, and verified the
signature for image tag 258f44877da3f9039f7a94b458b0aa6aaee75ebb.

Image Updater generated commit d18711d246b6a34661905b0d9fe42688e6e2d2d4.
PR #76 passed all 19 reported checks and merged at
be70575ffd89e26aafe2db9edefea8873660c86c.

Argo CD synchronized that exact revision. The frontend rollout completed,
the Application became Synced and Healthy, and its deployed tag matched.

This validates development delivery. It does not establish live staging
or production promotion, or the digest rollback required by step 8.11.

## References

- [GitOps overview](AVOS-GitOps-README.md)
- [Environment decision](../Docs/ADR/ADR-001-environment-account-state-model.md)
