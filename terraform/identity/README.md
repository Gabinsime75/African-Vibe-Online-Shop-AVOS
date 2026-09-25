# AVOS IAM Identity Center

This Terraform root manages the workforce authorization model for the African
Vibe Online Shop (AVOS).

It uses the AWS IAM Identity Center organization instance in `us-east-2` and
stores Terraform state in the encrypted AVOS S3 backend.

## Scope

This root manages:

- IAM Identity Center groups
- Permission sets
- AWS-managed policy attachments
- AWS account assignments
- Membership of the initial platform administrator
- Validation of the expected AWS account and Identity Center instance

Workforce authentication is provided by IAM Identity Center. Long-lived IAM
access keys are not the preferred administrative access method.

## Access model

| Group | Permission set | AWS policy | Session | Account assignment |
|---|---|---|---:|---|
| `AVOS-Platform-Admins` | `AVOS-AdministratorAccess` | `AdministratorAccess` | 1 hour | Management account |
| `AVOS-Security-Auditors` | `AVOS-SecurityAudit` | `SecurityAudit` | 1 hour | Management account |
| `AVOS-Developers` | `AVOS-DeveloperAccess` | `PowerUserAccess` | 4 hours | Deferred |
| `AVOS-ReadOnly` | `AVOS-ReadOnlyAccess` | `ReadOnlyAccess` | 4 hours | Deferred |

Developer and read-only assignments are intentionally deferred until dedicated
AVOS workload accounts exist. They must not be assigned to the unrelated
`DCT-PRODUCTION` account.

## Initial administrator

The initial administrator user is created through the IAM Identity Center
workforce-user onboarding process and discovered by Terraform using its
username.

Terraform manages the user's membership in `AVOS-Platform-Admins`; it does not
manage the user's password, MFA device, or recovery factors.

## Terraform files

| File | Purpose |
|---|---|
| `versions.tf` | Declares Terraform and AWS provider requirements |
| `backend.tf` | Declares the S3 remote backend |
| `providers.tf` | Configures the AWS provider and default tags |
| `variables.tf` | Defines configurable inputs and validations |
| `locals.tf` | Defines groups, permission sets, assignments, and common tags |
| `data.tf` | Discovers and validates the AWS account and Identity Center instance |
| `groups.tf` | Creates Identity Center groups |
| `users.tf` | Discovers the initial platform administrator |
| `group-memberships.tf` | Manages administrator group membership |
| `permission-sets.tf` | Creates permission sets |
| `managed-policy-attachments.tf` | Attaches AWS-managed policies |
| `account-assignments.tf` | Assigns groups and permission sets to AWS accounts |
| `outputs.tf` | Exposes non-sensitive identifiers for validation |

## Initialize

Create the operational backend configuration from the example:

```bash
cp backend.hcl.example backend.hcl