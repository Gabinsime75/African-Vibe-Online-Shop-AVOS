# Phase 7 Validation Report

## Scope and status

- Phase: CI, Software Supply Chain, and ECR Publication.
- Environment: AVOS development.
- AWS account: `396913735153`.
- AWS Region: `us-east-2`.
- Validation date: 2026-10-17.
- Status: Implementation validated; closeout documentation pending merge.
- Latest validated implementation commit:
  `fb60a25b895b838e82532b1e484ef93a73e73fad`.

Phase 7 produces tested, scanned, traceable, and signed container images.
Application deployment remains the responsibility of Phase 8 GitOps.

## Implementation coverage

| Step | Implementation |
| --- | --- |
| 7.1 | Reusable service workflow and validated service contract. |
| 7.2 | CI callers for 11 business services and loadgenerator. |
| 7.3 | Runtime validation, tests, and container builds. |
| 7.4 | Protobuf compatibility and generated-code drift checks. |
| 7.5 | Service, image, and infrastructure security scanning. |
| 7.6 | Image SBOMs, BuildKit provenance, and evidence checksums. |
| 7.7 | GitHub OIDC authentication with main-only AWS role trust. |
| 7.8 | Full source-SHA image tags and build identity validation. |
| 7.9 | Immutable ECR repositories and verified image publication. |
| 7.10 | Keyless image signing and identity-based verification. |
| 7.11 | Unique required checks and main-branch protection. |

## Service coverage

| Runtime | Services |
| --- | --- |
| Go | frontend, checkoutservice, productcatalogservice, shippingservice |
| Node.js | currencyservice, paymentservice |
| Python | emailservice, recommendationservice, shoppingassistantservice |
| Python | loadgenerator |
| Java | adservice |
| .NET | cartservice |

All 12 service workflows perform runtime-specific validation and build
Linux AMD64 container images. Test-execution checks reject missing or
non-executed tests where implemented.

The cartservice Docker build context is `src/cartservice/src`.
Other service contexts use their corresponding `src/<service>` directories.

## Contract protection

The protobuf workflow checks shared schema consistency, compilation,
and compatibility against the applicable baseline.

Independent Buf configurations cover the shared contracts and the distinct
cartservice schema. Compatibility uses the FILE policy.

Generated-code validation reproduces all 16 committed Go and Python binding
files using pinned generation tools. Separate Python environments accommodate
the services' dependency versions.

## Security validation

Trivy scans service files, built images, and Terraform configuration.
The infrastructure workflow also handles GitOps configuration when present.

The implemented blocking policy covers:

- Critical vulnerabilities.
- High and critical secret findings.
- High and critical configuration findings.

Reports are sanitized before artifact upload. Policy tests cover report
validation, severity thresholds, sanitization, and scoped exceptions.

Infrastructure exceptions require an exact finding ID and target path,
an owner, justification, compensating controls, review information,
and an expiry date. Wildcard and expired exceptions are rejected.

Image remediation included operating-system package updates and alignment
of the Java service's Netty dependencies.

Integration-test manifests received security configuration changes.
Those changes passed static scanning; runtime execution was not repeated
as part of this CI implementation.

## Build evidence

Each successful service build produces:

- A CycloneDX software bill of materials.
- BuildKit provenance and build metadata.
- Build-tool version information.
- An evidence manifest and SHA-256 checksums.
- References to the corresponding sanitized security reports.

Validation binds the source commit, image configuration digest,
Dockerfile, security results, and evidence files.

BuildKit provenance and SBOM files are retained as evidence.
They are not signed OCI attestations, and no SLSA level is claimed.

## AWS authentication and ECR

GitHub Actions authenticates through OIDC without stored AWS access keys.

The IAM role is `avos-dev-github-ci`. Its trust policy requires:

- Audience `sts.amazonaws.com`.
- The repository's immutable GitHub subject.
- The exact `main` branch reference.

A temporary feature-branch trust entry was used for positive authentication
testing and then removed. A subsequent authentication attempt from that
branch was denied. Main-branch authentication succeeded after merge.

Terraform manages 12 repositories under `avos/dev/`, a dedicated ECR KMS
key and alias, repository lifecycle policies, and publication permissions.

Repositories use:

- Immutable image tags.
- KMS encryption.
- Scan on push.
- Disabled forced repository deletion.
- Seven-day expiration for untagged images.

Tagged source-SHA images are retained. Deployment-aware retention and
cleanup belong to later promotion and cost-control work.

The publication role is scoped to the AVOS repositories. Each service
session is further restricted to its intended repository.

Publication rechecks the remote manifest digest and image configuration.
An existing SHA tag is accepted only when it identifies the expected image.
Conflicting images and unrelated registry failures are rejected.

## Signing and verification

Cosign v3.1.3 is installed using a pinned binary SHA-256 checksum.

After successful publication, CI signs the verified ECR digest using
keyless GitHub OIDC authentication. Verification requires:

- The exact reusable workflow identity on `main`.
- Issuer `https://token.actions.githubusercontent.com`.
- The workflow source commit.
- A digest-qualified image reference.

The verification policy is stored in
`.github/policies/image-verification.json`.

Signing evidence includes the signature bundle, verification results,
and a receipt linking the policy and publication evidence by checksum.

The final signing audit verified all 12 evidence chains against live ECR
digests for commit:

`dc9f7b8338e2b6a8c5c1b570d3a735d8da8a9320`

This audit checked evidence consistency and live registry identity.
Cryptographic signature verification ran within the CI workflows.

## Repository protection

All service, protobuf, and infrastructure validation workflows run on every
pull request. Push workflows retain their existing path filters.

Service check names are unique. Main-branch protection requires 18 checks
from the GitHub Actions app:

- Twelve service validation checks.
- Two protobuf checks.
- One infrastructure security check.
- Markdown lint, secret scanning, and tracked-file hygiene.

Protection also requires an up-to-date branch, resolved conversations,
pull requests, and linear history. Administrator enforcement is enabled.
Force pushes and branch deletion are blocked.

Required approvals are zero for the current single-owner setup.
CODEOWNERS remains configured, but independent approval is not enforced.

GitGuardian provides an additional successful check outside the configured
18 required GitHub Actions checks.

PR #61 merged through the protected merge path without an administrator
bypass.

Branch protection was configured through the GitHub API. It is not managed
by the AWS Terraform configuration.

## Validation evidence

| Validation | Result |
| --- | --- |
| Local supply-chain unit tests | 13 passed |
| Local security policy tests | 9 passed |
| Java behavioral tests | 4 passed |
| Actionlint and scoped whitespace checks | Passed |
| PR #59 service and protobuf implementation | Merged |
| PR #60 image signing implementation | 16 checks passed; merged |
| Signing evidence audit | All 12 chains matched live ECR digests |
| PR #61 enforceable CI checks | 19 checks passed; merged |
| PR #61 post-merge workflows | All triggered workflows passed |
| Terraform CI convergence | No changes |
| Protected merge validation | PR #61 merged under active protection |

Implementation pull requests:

- [PR #59: Service CI and ECR publication][pr59]
- [PR #60: Image signing and verification][pr60]
- [PR #61: Enforceable PR validation][pr61]

Validation commits:

- Initial ECR publication:
  `32fda7d8cbc022c8e1c8e6fa4684397f481f85a2`.
- Signing and audited evidence:
  `dc9f7b8338e2b6a8c5c1b570d3a735d8da8a9320`.
- Required-check implementation:
  `fb60a25b895b838e82532b1e484ef93a73e73fad`.

## Operational limitations

- Workflow artifacts use seven-day retention; infrastructure security
  reports use the retention configured in their workflow.
- Downloaded evidence was preserved separately from the Git repository.
- Time-bound infrastructure exceptions require review before expiry.
- Signature verification is implemented in CI, not cluster admission.
- SBOM and provenance attestations are not signed.
- No application deployment or GitOps image update occurs in CI.

## Phase 8 handoff

Phase 8 implements GitOps, Image Updater, environment promotion,
and rollback.

The delivery implementation must:

1. Consume images from the AVOS ECR repositories.
2. Preserve source-SHA and digest traceability.
3. Define how signature verification gates deployment.
4. Use Argo CD Image Updater for approved Git image updates.
5. Keep Git as the authoritative deployment record.
6. Establish environment promotion and rollback controls.
7. Define registry read access without reusing CI publication credentials.

Phase 7 does not install Argo CD, deploy business workloads, or modify
GitOps image references.

## Closeout

Implementation and infrastructure validation have passed.

Merge this report through the protected PR process before creating the
Phase 7 completion tag.

[pr59]: https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/pull/59
[pr60]: https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/pull/60
[pr61]: https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/pull/61
