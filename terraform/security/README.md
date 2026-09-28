# AVOS Security Foundation

This Terraform root implements the regional security detection and secrets-encryption foundation for the African Vibe Online Shop (AVOS).

The configuration was built from scratch specifically for AVOS. It is independently managed through the remote Terraform state:

```text
security/terraform.tfstate
```

## Scope

The current implementation covers:

| Setting | Value |
|---|---|
| AWS account | `396913735153` |
| AWS Region | `us-east-2` |
| Environment | `dev` |
| Terraform root | `terraform/security` |
| Remote-state key | `security/terraform.tfstate` |

The security root currently manages:

- Amazon GuardDuty
- GuardDuty optional protection plans
- AWS Security Hub CSPM
- AWS Foundational Security Best Practices
- CIS AWS Foundations Benchmark
- Amazon Detective
- IAM Access Analyzer
- AWS KMS key for application secrets

## Security Architecture

```text
AWS accounts, identities, resources, and activity
                       |
          +------------+-------------+
          |                          |
     GuardDuty                 Access Analyzer
          |                          |
   Threat detection         External-access analysis
          |
          v
     Security Hub
  Findings aggregation
  Compliance evaluation
          |
          v
   Amazon Detective
 Investigation and behavior graph
```

Application secrets will use the following encryption path:

```text
AVOS workload
      |
      v
AWS Secrets Manager
      |
      v
alias/avos-dev-secrets
      |
      v
Customer-managed AWS KMS key
```

## Amazon GuardDuty

Amazon GuardDuty continuously analyzes supported AWS telemetry and data sources for malicious, suspicious, or unauthorized activity.

The AVOS detector uses the following configuration:

| Setting | Value |
|---|---|
| Status | Enabled |
| Region | `us-east-2` |
| Finding publication frequency | 15 minutes |
| Detector ID | `a89441bc25ad4ce28ce1d144f3732551` |

### Foundational data sources

GuardDuty automatically manages its foundational data sources:

- AWS CloudTrail management events
- VPC Flow Logs
- DNS query logs

These foundational sources are returned by the GuardDuty API but are not managed through separate `aws_guardduty_detector_feature` resources.

### Optional protection plans

Terraform explicitly manages the following optional GuardDuty features:

| Feature | Terraform status |
|---|---|
| S3 data events | Enabled |
| EKS audit logs | Enabled |
| EBS malware protection | Enabled |
| RDS login events | Enabled |
| Lambda network logs | Enabled |
| Runtime Monitoring | Disabled |

The optional features are managed through:

```hcl
resource "aws_guardduty_detector_feature" "this"
```

A Terraform map and `for_each` create one independently managed resource for each protection plan.

### Runtime Monitoring

Runtime Monitoring is intentionally disabled until AVOS deploys supported EKS, ECS, or EC2 workloads and establishes the required GuardDuty security-agent lifecycle.

The following Runtime Monitoring agent-management features are explicitly disabled:

- `EC2_AGENT_MANAGEMENT`
- `ECS_FARGATE_AGENT_MANAGEMENT`
- `EKS_ADDON_MANAGEMENT`

Explicitly declaring these disabled settings prevents perpetual Terraform differences and makes future enablement a reviewed infrastructure change.

`EKS_RUNTIME_MONITORING` is not configured because AWS recommends using the consolidated `RUNTIME_MONITORING` feature for new implementations.

### AI-related GuardDuty features

The GuardDuty API currently reports the following additional features:

- `AI_PROTECTION`
- `AI_ANALYST`

These features are currently disabled and are not managed through the installed Terraform AWS provider because they are not accepted by the current `aws_guardduty_detector_feature` resource schema.

They will be reconsidered when:

- AVOS deploys Amazon Bedrock or Amazon SageMaker workloads
- The Terraform AWS provider supports the features
- Cost and operational requirements have been reviewed

## AWS Security Hub CSPM

AWS Security Hub Cloud Security Posture Management is enabled in `us-east-2`.

Security Hub aggregates security findings and continuously evaluates the account against enabled security standards.

The AVOS configuration is:

| Setting | Value |
|---|---|
| Security Hub | Enabled |
| Default standards | Disabled |
| Automatically enable new controls | Enabled |
| Finding generator | `SECURITY_CONTROL` |
| Consolidated control findings | Enabled |

### Explicit standards management

The configuration uses:

```hcl
enable_default_standards = false
```

This prevents AWS from implicitly selecting compliance standards. Terraform explicitly controls the AVOS compliance baseline.

### Enabled security standards

| Standard | Version |
|---|---|
| AWS Foundational Security Best Practices | `1.0.0` |
| CIS AWS Foundations Benchmark | `3.0.0` |

#### AWS Foundational Security Best Practices

AWS Foundational Security Best Practices evaluates AWS resources against AWS-developed security recommendations.

It includes controls covering services such as:

- AWS CloudTrail
- AWS Config
- Amazon EC2
- Amazon EKS
- Elastic Load Balancing
- AWS IAM
- AWS KMS
- Amazon RDS
- Amazon S3
- AWS Secrets Manager

#### CIS AWS Foundations Benchmark

CIS AWS Foundations Benchmark v3.0.0 evaluates foundational AWS account controls based on the Center for Internet Security benchmark.

It focuses on areas such as:

- Identity and access management
- Root-user protections
- Logging
- Monitoring
- Network security
- Encryption
- Security-service configuration

### Consolidated control findings

The following setting enables consolidated findings:

```hcl
control_finding_generator = "SECURITY_CONTROL"
```

When the same control belongs to multiple standards, Security Hub generates one standard-independent control finding instead of creating duplicate findings for every enabled standard.

This simplifies:

- Alert processing
- Reporting
- EventBridge automation
- Ticket creation
- Future AI-assisted security analysis

## Amazon Detective

Amazon Detective is enabled through a regional behavior graph.

| Setting | Value |
|---|---|
| Region | `us-east-2` |
| Graph ARN | `arn:aws:detective:us-east-2:396913735153:graph:2e07eb0e2b7e43a896fd5c6f9373994e` |
| Graph owner | AVOS management account |

Detective supports security investigations by correlating historical activity and relationships involving:

- AWS identities
- AWS API activity
- Network activity
- AWS resources
- GuardDuty findings
- Related security events

The service complements GuardDuty and Security Hub:

- GuardDuty detects suspicious activity.
- Security Hub aggregates and prioritizes findings.
- Detective helps investigate how the activity occurred and which resources were involved.

The current graph covers only the AVOS management account.

Organization-wide Detective administration is deferred until AVOS has a dedicated Security Tooling account.

## IAM Access Analyzer

IAM Access Analyzer is enabled for external-access analysis.

| Setting | Value |
|---|---|
| Analyzer name | `avos-dev-external-access` |
| Analyzer type | `ACCOUNT` |
| Zone of trust | Account `396913735153` |
| Expected status | `ACTIVE` |

The analyzer evaluates resource-based policies to identify resources that can be accessed from outside the account.

Supported findings can include public or cross-account access involving:

- Amazon S3 bucket policies
- AWS KMS key policies
- IAM role trust policies
- Amazon SQS queue policies
- Amazon SNS topic policies
- Amazon ECR repository policies
- AWS Secrets Manager resource policies
- Lambda resource policies

A finding means access is possible based on policy configuration. It does not prove that the external principal has used that access.

The account-level zone of trust prevents the unrelated `DCT-PRODUCTION` account from being treated as part of the AVOS security boundary.

### Deferred Access Analyzer capabilities

The following analyzer types are deferred:

- Organization external-access analysis
- Account internal-access analysis
- Organization internal-access analysis
- Account unused-access analysis
- Organization unused-access analysis

Unused-access analysis is a paid capability and will be evaluated when the AVOS identity estate contains enough roles and workloads to justify continuous analysis.

## AWS Secrets Manager and KMS

AWS Secrets Manager does not require account-level activation.

Secret containers will be created only when a specific AVOS workload has a defined secret requirement.

Examples could include:

- Database credentials
- Third-party API tokens
- Application signing material
- OAuth client secrets
- External payment-provider credentials
- AI-service integration credentials

AVOS does not create empty Secrets Manager placeholders for every service because:

- Several services currently have no secret requirement.
- Empty secrets provide no security value.
- Secrets Manager charges per secret.
- Secret ownership should remain with the consuming workload.
- Secret rotation requirements vary by secret type.

## Secrets KMS Key

The security root provides a dedicated customer-managed KMS key for future AVOS secrets.

| Setting | Value |
|---|---|
| Alias | `alias/avos-dev-secrets` |
| Key ID | `2876072b-203d-4c4d-bb56-ce28fa59efbf` |
| Key type | Symmetric |
| Key usage | Encrypt and decrypt |
| Key state | Enabled |
| Automatic rotation | Enabled |
| Rotation period | 365 days |
| Deletion window | 30 days |
| Multi-Region | No |

### Symmetric encryption

Secrets Manager uses symmetric KMS keys to generate and decrypt data keys.

An asymmetric KMS key is not appropriate for the Secrets Manager envelope-encryption workflow.

### Automatic rotation

The key uses:

```hcl
enable_key_rotation     = true
rotation_period_in_days = 365
```

AWS automatically creates new key material every 365 days.

Existing secret versions remain decryptable because AWS KMS retains the previous key-material versions.

### Deletion protection window

The key uses:

```hcl
deletion_window_in_days = 30
```

If Terraform destroys the key resource, AWS schedules deletion instead of deleting the key immediately.

The 30-day waiting period provides time to cancel an accidental deletion before encrypted data becomes permanently unrecoverable.

### Single-Region key

The current key uses:

```hcl
multi_region = false
```

The AVOS baseline currently operates in `us-east-2`. Using a single-Region key avoids implying that cross-Region disaster recovery has already been implemented.

A multi-Region secrets and encryption strategy will be designed when AVOS implements its disaster-recovery Region.

### KMS key policy

Every KMS key requires a resource-based key policy.

The AVOS key policy grants the account principal:

```text
arn:aws:iam::396913735153:root
```

permission to delegate KMS permissions through IAM policies.

This ARN represents the AWS account principal. It does not mean that AVOS workloads use root-user credentials.

Future application roles will require both:

- Secrets Manager permissions, such as `secretsmanager:GetSecretValue`
- KMS permissions, such as `kms:Decrypt`

Permissions will be restricted to the exact secret and KMS key required by each workload.

## Secret-Value Handling Policy

Terraform must not contain:

- Plaintext passwords
- API tokens
- Private keys
- Client secrets
- Secret strings
- Generated application credentials
- Secret values in `terraform.tfvars`
- Secret values in Terraform outputs

Terraform may create Secrets Manager metadata, but secret values must be injected through a controlled process outside Terraform state.

Approved future methods may include:

- AWS CLI with protected input
- Application deployment automation
- Secret rotation workflows
- Secure CI/CD environment secrets
- AWS service-managed credentials

## Organization-Wide Security Administration

Organization-wide GuardDuty, Security Hub, Detective, and IAM Access Analyzer administration is intentionally deferred.

The approved AVOS organization contains a `Security` organizational unit, but it does not yet contain a dedicated Security Tooling account.

AWS recommends separating the Organizations management account from the delegated security administrator.

The unrelated `DCT-PRODUCTION` account will not be used as an AVOS security administrator.

A future AVOS Security Tooling account should become the aligned delegated administrator for:

- Amazon GuardDuty
- AWS Security Hub CSPM
- Amazon Detective
- IAM Access Analyzer
- Future security automation

This keeps centralized security administration separate from:

- Billing administration
- Organization management
- Application workloads
- Production workloads

## Terraform Files

| File | Purpose |
|---|---|
| `access-analyzer.tf` | Creates the account-level external-access analyzer |
| `backend.tf` | Declares the S3 remote backend |
| `backend.hcl.example` | Documents required backend configuration |
| `data.tf` | Reads AWS account, partition, and organization information |
| `detective.tf` | Creates the regional Detective behavior graph |
| `guardduty.tf` | Creates the GuardDuty detector and managed features |
| `kms-secrets.tf` | Creates the Secrets Manager KMS key and alias |
| `locals.tf` | Defines names, tags, standards, and feature maps |
| `outputs.tf` | Exposes non-sensitive resource identifiers |
| `providers.tf` | Configures the AWS provider |
| `securityhub.tf` | Enables Security Hub and its standards |
| `terraform.tfvars.example` | Documents environment variable values |
| `variables.tf` | Declares configurable root-module inputs |
| `versions.tf` | Defines Terraform and provider requirements |

## Prerequisites

Before using this Terraform root, ensure that:

- Terraform is installed.
- AWS CLI is installed.
- AWS Identity Center is configured.
- The `avos-admin` CLI profile exists.
- The Identity Center session is active.
- Phase 2 created the Terraform backend.
- The backend S3 bucket exists.
- The backend KMS key exists.
- The operator has permission to manage the security services.

Authenticate with AWS Identity Center:

```bash
aws sso login \
  --profile avos-admin
```

Verify the active identity:

```bash
aws sts get-caller-identity \
  --profile avos-admin \
  --query '{
    Account:Account,
    Arn:Arn,
    UserId:UserId
  }' \
  --output table
```

Set the environment variables used by Terraform:

```bash
export AWS_PROFILE="avos-admin"
export AWS_REGION="us-east-2"
export AWS_DEFAULT_REGION="us-east-2"
```

## Backend Initialization

Navigate to the security root:

```bash
cd terraform/security
```

Copy the backend example:

```bash
cp backend.hcl.example backend.hcl
```

Replace the placeholders in `backend.hcl` with the actual Phase 2 backend values.

Example structure:

```hcl
bucket       = "REPLACE_WITH_STATE_BUCKET"
key          = "security/terraform.tfstate"
region       = "us-east-2"
encrypt      = true
kms_key_id   = "REPLACE_WITH_TERRAFORM_STATE_KMS_KEY_ARN"
use_lockfile = true
```

Initialize Terraform:

```bash
terraform init \
  -reconfigure \
  -backend-config=backend.hcl
```

The local `backend.hcl` file must remain untracked because it contains environment-specific backend identifiers.

## Variable Configuration

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the local values as required.

The local `terraform.tfvars` file must remain untracked.

Verify that Git ignores both local configuration files:

```bash
git check-ignore -v \
  terraform/security/backend.hcl \
  terraform/security/terraform.tfvars
```

## Terraform Workflow

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

### Create a saved plan

```bash
terraform plan \
  -out=security.tfplan \
  -detailed-exitcode
```

Terraform detailed exit codes are:

| Exit code | Meaning |
|---|---|
| `0` | No changes |
| `1` | Terraform error |
| `2` | Infrastructure changes are proposed |

### Review the saved plan

```bash
terraform show \
  -no-color \
  security.tfplan
```

### Apply the reviewed plan

```bash
terraform apply \
  security.tfplan
```

### Verify convergence

```bash
terraform plan \
  -detailed-exitcode
```

A final exit code of `0` means the deployed AWS infrastructure matches the Terraform configuration.

## Validation Commands

### GuardDuty detector

```bash
aws guardduty list-detectors \
  --region us-east-2 \
  --profile avos-admin \
  --output json
```

### GuardDuty features

```bash
AVOS_GUARDDUTY_DETECTOR_ID="$(
  aws guardduty list-detectors \
    --region us-east-2 \
    --profile avos-admin \
    --query 'DetectorIds[0]' \
    --output text
)"

aws guardduty get-detector \
  --detector-id "$AVOS_GUARDDUTY_DETECTOR_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'Features[].{
    Name:Name,
    Status:Status
  }' \
  --output table
```

### Security Hub

```bash
aws securityhub describe-hub \
  --region us-east-2 \
  --profile avos-admin \
  --query '{
    HubArn:HubArn,
    AutoEnableControls:AutoEnableControls,
    ControlFindingGenerator:ControlFindingGenerator
  }' \
  --output table
```

### Security Hub standards

```bash
aws securityhub get-enabled-standards \
  --region us-east-2 \
  --profile avos-admin \
  --query 'StandardsSubscriptions[].{
    Standard:StandardsArn,
    Status:StandardsStatus
  }' \
  --output table
```

### Detective

```bash
aws detective list-graphs \
  --region us-east-2 \
  --profile avos-admin \
  --query 'GraphList[].{
    GraphArn:Arn,
    CreatedTime:CreatedTime
  }' \
  --output table
```

### Access Analyzer

```bash
aws accessanalyzer list-analyzers \
  --region us-east-2 \
  --profile avos-admin \
  --query 'analyzers[].{
    Name:name,
    Type:type,
    Status:status,
    Arn:arn
  }' \
  --output table
```

### Secrets KMS key

```bash
aws kms describe-key \
  --key-id alias/avos-dev-secrets \
  --region us-east-2 \
  --profile avos-admin \
  --query 'KeyMetadata.{
    KeyId:KeyId,
    Arn:Arn,
    Enabled:Enabled,
    KeyUsage:KeyUsage,
    KeySpec:KeySpec,
    MultiRegion:MultiRegion,
    KeyState:KeyState
  }' \
  --output table
```

### Secrets KMS key rotation

Resolve the alias to the key ID:

```bash
AVOS_SECRETS_KMS_KEY_ID="$(
  aws kms describe-key \
    --key-id alias/avos-dev-secrets \
    --region us-east-2 \
    --profile avos-admin \
    --query 'KeyMetadata.KeyId' \
    --output text
)"
```

Then check rotation:

```bash
aws kms get-key-rotation-status \
  --key-id "$AVOS_SECRETS_KMS_KEY_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query '{
    KeyRotationEnabled:KeyRotationEnabled,
    RotationPeriodInDays:RotationPeriodInDays,
    NextRotationDate:NextRotationDate
  }' \
  --output table
```

## Terraform Outputs

Display all non-sensitive outputs:

```bash
terraform output
```

The root exposes:

- GuardDuty detector ID
- GuardDuty feature statuses
- Security Hub account ID
- Security Hub standard subscription IDs
- Detective graph ARN
- Access Analyzer ARN
- Secrets KMS key ID
- Secrets KMS key ARN
- Secrets KMS alias

## Operational Considerations

- GuardDuty findings may take time to appear.
- Security Hub standards can initially report `PENDING`.
- Security Hub requires AWS Config for many resource controls.
- Detective requires time to build historical behavioral context.
- Access Analyzer findings may not be immediately available.
- Runtime Monitoring remains disabled until its agents are designed.
- KMS key deletion is delayed for 30 days.
- Removing a GuardDuty feature resource from Terraform state does not necessarily disable the corresponding AWS feature.
- Never destroy this root without reviewing the impact on encrypted secrets.
- A deleted KMS key can make encrypted secret data permanently unrecoverable after the deletion window expires.

## Cost Considerations

Potential costs include:

- GuardDuty data analysis and optional protection plans
- Security Hub security checks
- Detective behavior-graph ingestion
- Customer-managed KMS key monthly charges
- KMS API requests
- Future Secrets Manager secret storage
- Future Secrets Manager API calls
- Future secret rotation functions

Unused-access analysis and GuardDuty Runtime Monitoring are intentionally deferred until their value and cost can be evaluated against deployed AVOS workloads.

## Current Deferred Items

The following items are intentionally deferred:

- Dedicated AVOS Security Tooling account
- Organization-wide security-service administration
- Organization-level Access Analyzer
- Paid unused-access analysis
- GuardDuty Runtime Monitoring
- GuardDuty security-agent deployment
- GuardDuty AI Protection
- GuardDuty AI Analyst
- Cross-Region Security Hub aggregation
- Multi-Region KMS keys
- Secrets Manager secret containers
- Secret-value injection
- Automated secret rotation
- EventBridge security remediation
- Systems Manager Automation runbooks
- AI-assisted finding analysis and remediation

These are implementation decisions, not configuration drift.

They will be added during the appropriate AVOS workload, multi-account, observability, and AI-assisted operations phases.