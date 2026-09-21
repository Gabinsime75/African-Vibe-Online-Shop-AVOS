# AVOS Terraform Bootstrap

## Purpose

This bootstrap creates the protected AWS resources used to store and lock
Terraform state for AVOS.

The bootstrap is intentionally created with local state first because Terraform
cannot use an S3 backend before the S3 bucket and KMS key exist.

## Bootstrap sequence

1. Initialize Terraform with local state.
2. Create the KMS key and alias.
3. Create and protect the S3 state bucket.
4. Apply the bootstrap configuration.
5. Add the partial S3 backend configuration.
6. Migrate local state into S3.
7. Validate native S3 state locking and version recovery.

## Environment model

The initial implementation deploys the AVOS development environment into the
existing AWS account.

The design supports moving staging and production into separate AWS accounts
later without changing the state naming model.

| Setting | Development value |
|---|---|
| AWS account | `396913735153` |
| AWS Region | `us-east-2` |
| Environment | `dev` |
| State bucket | `avos-dev-tfstate-396913735153-us-east-2` |
| State key | `bootstrap/terraform.tfstate` |
| Locking | Native S3 lock file |
| Encryption | Customer-managed AWS KMS key |

The environment and account decision is recorded in
[`../../Docs/ADR/ADR-001-environment-account-state-model.md`](../../Docs/ADR/ADR-001-environment-account-state-model.md).

## Configuration files

| File | Purpose |
|---|---|
| `versions.tf` | Defines compatible Terraform and AWS provider versions. |
| `providers.tf` | Configures the AWS provider, expected account, Region, and default tags. |
| `variables.tf` | Declares configurable input values and validation rules. |
| `locals.tf` | Calculates names, state keys, and common tags. |
| `data.tf` | Reads the active AWS account identity. |
| `kms.tf` | Creates the state-encryption KMS key and alias. |
| `s3.tf` | Creates and protects the versioned S3 state bucket. |
| `s3-policy.tf` | Denies access to the state bucket over insecure transport. |
| `outputs.tf` | Exposes backend names, identifiers, and configuration values. |
| `backend.tf` | Declares a partial S3 backend. |
| `backend.hcl.example` | Documents the required backend configuration. |
| `terraform.tfvars.example` | Documents the required input variables. |
| `.terraform.lock.hcl` | Pins provider selections for reproducible initialization. |

## Security controls

The bootstrap implements:

- Customer-managed KMS encryption
- Automatic KMS key rotation
- KMS deletion protection through a delayed deletion window
- Terraform `prevent_destroy` protection
- S3 versioning
- Native S3 state locking
- S3 Bucket Keys
- Bucket-owner-enforced object ownership
- Complete S3 public-access blocking
- Denial of unencrypted transport
- Noncurrent state-version retention
- Account-ID validation
- Mandatory AVOS resource tags

## Local files

Create local configuration from the committed examples:

```bash
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl