# AVOS Network Foundation

This Terraform root implements the AWS network foundation for the African Vibe
Online Shop (AVOS).

It was built from scratch for AVOS and is independently managed through the
remote Terraform state:

```text
network/terraform.tfstate
```

## Architecture summary

The development network contains:

- One dedicated VPC
- Three Availability Zones
- Three public subnets
- Three private application subnets
- Three private data subnets
- One Internet Gateway
- One development NAT Gateway
- Separate route tables for each private subnet
- Amazon S3 and DynamoDB Gateway VPC endpoints
- Encrypted VPC Flow Logs
- A restricted default VPC security group

## Network flow

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public subnets
   |
   +-- Future public Application Load Balancer
   |
   +-- NAT Gateway in us-east-2a
             |
             v
      Private application subnets
             |
             +-- Future EKS nodes and application workloads
             |
             +-- S3 Gateway endpoint
             |
             +-- DynamoDB Gateway endpoint

Private data subnets
   |
   +-- Future databases and caches
   |
   +-- S3 Gateway endpoint
   |
   +-- DynamoDB Gateway endpoint
```

Private data subnets do not have a default route to an Internet Gateway or NAT
Gateway.

## Address plan

### VPC

```text
10.20.0.0/16
```

### Subnets

| Tier | Availability Zone | CIDR |
|---|---|---|
| Public | `us-east-2a` | `10.20.0.0/20` |
| Public | `us-east-2b` | `10.20.16.0/20` |
| Public | `us-east-2c` | `10.20.32.0/20` |
| Private application | `us-east-2a` | `10.20.64.0/20` |
| Private application | `us-east-2b` | `10.20.80.0/20` |
| Private application | `us-east-2c` | `10.20.96.0/20` |
| Private data | `us-east-2a` | `10.20.128.0/20` |
| Private data | `us-east-2b` | `10.20.144.0/20` |
| Private data | `us-east-2c` | `10.20.160.0/20` |

Every subnet is a `/20`, providing 4,096 IPv4 addresses before AWS reserves
five addresses in each subnet.

## Subnet responsibilities

### Public subnets

Public subnets contain infrastructure that must interact directly with the
internet.

Expected resources include:

- Internet-facing Application Load Balancers
- NAT Gateways
- Other explicitly approved internet-facing entry points

A subnet is public because its route table contains:

```text
0.0.0.0/0 -> Internet Gateway
```

Automatic public IPv4 assignment remains disabled. Resources receive public
addresses only when explicitly configured to do so.

### Private application subnets

Private application subnets are intended for:

- Amazon EKS worker nodes
- Kubernetes application pods
- Internal load balancers
- Private compute services
- Application-tier resources

Their default route points to the approved NAT Gateway:

```text
0.0.0.0/0 -> NAT Gateway
```

This permits workloads to initiate outbound internet connections without
accepting unsolicited inbound internet connections.

### Private data subnets

Private data subnets are intended for:

- Relational databases
- Caches
- Stateful platform services
- Other data-tier resources

They do not have a default internet route.

They can reach S3 and DynamoDB through the Gateway VPC endpoints, subject to
IAM and resource-policy authorization.

## NAT strategy

The development environment uses one public NAT Gateway in `us-east-2a`.

This is a deliberate cost optimization.

### Development

```text
NAT mode = single
```

All private application subnets use the NAT Gateway in `us-east-2a`.

### Staging and production

Higher environments should use:

```text
NAT mode = per_az
```

A NAT Gateway per Availability Zone improves availability and avoids routing
private application egress across Availability Zone boundaries.

## Gateway VPC endpoints

The network provides Gateway endpoints for:

- Amazon S3
- Amazon DynamoDB

The endpoints are associated with:

- Three private application route tables
- Three private data route tables

They are not associated with the public route table.

Gateway endpoints allow S3 and DynamoDB traffic to remain on AWS-managed
network paths and avoid unnecessary NAT Gateway processing.

The endpoint route does not grant authorization. Workloads still require
appropriate IAM permissions and must satisfy applicable bucket, key, table,
and endpoint policies.

Interface VPC endpoints are intentionally deferred until their consumers are
implemented because they incur recurring hourly charges in each selected
Availability Zone.

## Kubernetes subnet tags

Public subnets contain:

```text
kubernetes.io/role/elb = 1
```

Private application subnets contain:

```text
kubernetes.io/role/internal-elb = 1
```

These tags support subnet discovery by Kubernetes-integrated AWS controllers.

They do not create load balancers or independently grant network access.

## VPC Flow Logs

VPC Flow Logs capture metadata for accepted and rejected traffic across the
VPC.

The implementation uses:

- Traffic type `ALL`
- A 60-second maximum aggregation interval
- Amazon CloudWatch Logs
- A 30-day retention period
- A dedicated IAM delivery role
- A dedicated customer-managed KMS key
- Annual KMS key rotation

The CloudWatch Logs group is:

```text
/aws/vpc/flow-logs/avos-dev
```

The KMS alias is:

```text
alias/avos-dev-vpc-flow-logs
```

Flow Logs capture network metadata, not application payloads.

Typical use cases include:

- Troubleshooting rejected traffic
- Investigating unexpected connections
- Reviewing source and destination addresses
- Identifying traffic patterns
- Supporting security investigations
- Feeding future observability and AIOps workflows

## Security baseline

### Default security group

The VPC default security group is managed by Terraform with:

```text
Ingress rules: 0
Egress rules:  0
```

AVOS resources must use purpose-built security groups.

Examples that will be introduced by downstream phases include:

- Public ALB security group
- Internal ALB security group
- EKS control-plane security group
- EKS node security group
- Database security group
- Cache security group
- Interface endpoint security group

### Network ACLs

The initial foundation retains the default network ACL behavior.

Security groups are the primary network-access control because they are
stateful and can reference other security groups.

Custom network ACLs should be introduced only when AVOS has a specific
subnet-boundary, explicit-deny, or compliance requirement.

## Terraform file structure

| File | Purpose |
|---|---|
| `versions.tf` | Defines Terraform and provider version requirements |
| `providers.tf` | Configures the AWS provider and default tags |
| `backend.tf` | Declares the remote S3 backend |
| `backend.hcl.example` | Documents the required backend configuration |
| `variables.tf` | Declares configurable network inputs and validation |
| `locals.tf` | Builds naming, tags, NAT placement, and derived values |
| `terraform.tfvars.example` | Provides a safe example variable configuration |
| `checks.tf` | Validates architectural relationships across variables |
| `vpc.tf` | Creates the AVOS VPC |
| `subnets.tf` | Creates public, private application, and private data subnets |
| `public-routing.tf` | Creates the Internet Gateway and public routing |
| `nat-gateways.tf` | Creates NAT Elastic IPs and NAT Gateways |
| `private-application-routing.tf` | Creates private application routes through NAT |
| `private-data-routing.tf` | Creates isolated private data route tables |
| `vpc-endpoints-gateway.tf` | Creates S3 and DynamoDB Gateway endpoints |
| `flow-logs-kms.tf` | Creates the Flow Logs KMS key and alias |
| `flow-logs-cloudwatch.tf` | Creates the CloudWatch Logs destination |
| `flow-logs-iam.tf` | Creates the Flow Logs delivery role and permissions |
| `flow-logs.tf` | Enables VPC Flow Logs |
| `default-security-group.tf` | Removes all default security-group rules |
| `outputs.tf` | Publishes stable values for downstream Terraform roots |

Terraform loads all `.tf` files in this directory as one root module. File
names organize the configuration for humans but do not define execution order.

Terraform derives dependencies from resource references.

## Prerequisites

Before using this root, verify:

- Terraform is installed.
- AWS CLI is installed.
- The `avos-admin` AWS IAM Identity Center profile exists.
- The SSO session is active.
- The Phase 2 Terraform state bucket and KMS key exist.
- The current identity has permission to manage the required networking,
  IAM, KMS, CloudWatch Logs, and EC2 resources.

Authenticate:

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

Set the shell environment:

```bash
export AWS_PROFILE="avos-admin"
export AWS_REGION="us-east-2"
export AWS_DEFAULT_REGION="us-east-2"
```

## Backend configuration

`backend.tf` declares that this root uses an S3 backend:

```hcl
terraform {
  backend "s3" {}
}
```

The actual account-specific values are supplied through an ignored
`backend.hcl` file.

Create it from the example:

```bash
cd terraform/networking
cp backend.hcl.example backend.hcl
```

Replace the placeholders with the protected Phase 2 backend values:

```hcl
bucket       = "avos-dev-tfstate-396913735153-us-east-2"
key          = "network/terraform.tfstate"
region       = "us-east-2"
encrypt      = true
kms_key_id   = "arn:aws:kms:us-east-2:396913735153:key/5dfe4f50-b095-4317-b7a8-28a8c21f7efe"
use_lockfile = true
```

Do not commit `backend.hcl`.

Initialize the backend:

```bash
terraform init \
  -reconfigure \
  -backend-config=backend.hcl
```

From the repository root, the equivalent command is:

```bash
terraform -chdir=terraform/networking init \
  -reconfigure \
  -backend-config=backend.hcl
```

## Variable configuration

Create the ignored working configuration:

```bash
cd terraform/networking
cp terraform.tfvars.example terraform.tfvars
```

Review every value before planning.

Do not commit `terraform.tfvars`.

The example configuration represents the approved development architecture:

```hcl
aws_region  = "us-east-2"
environment = "dev"
project     = "AVOS"

vpc_cidr = "10.20.0.0/16"

availability_zones = [
  "us-east-2a",
  "us-east-2b",
  "us-east-2c"
]

public_subnet_cidrs = {
  us-east-2a = "10.20.0.0/20"
  us-east-2b = "10.20.16.0/20"
  us-east-2c = "10.20.32.0/20"
}

private_application_subnet_cidrs = {
  us-east-2a = "10.20.64.0/20"
  us-east-2b = "10.20.80.0/20"
  us-east-2c = "10.20.96.0/20"
}

private_data_subnet_cidrs = {
  us-east-2a = "10.20.128.0/20"
  us-east-2b = "10.20.144.0/20"
  us-east-2c = "10.20.160.0/20"
}

nat_gateway_mode       = "single"
single_nat_gateway_az  = "us-east-2a"
flow_log_retention_days = 30
```

Use the exact variable names defined in the current `variables.tf` and
`terraform.tfvars.example` if they differ from the illustrative block above.

## Standard workflow

Run commands from the repository root unless otherwise stated.

### Format

```bash
terraform -chdir=terraform/networking fmt \
  -recursive
```

Check formatting without modifying files:

```bash
terraform -chdir=terraform/networking fmt \
  -check \
  -recursive
```

### Initialize

```bash
terraform -chdir=terraform/networking init \
  -reconfigure \
  -backend-config=backend.hcl
```

### Validate

```bash
terraform -chdir=terraform/networking validate
```

### Plan

```bash
terraform -chdir=terraform/networking plan \
  -out=network.tfplan \
  -detailed-exitcode

PLAN_EXIT_CODE=$?
echo "Terraform plan exit code: $PLAN_EXIT_CODE"
```

Exit-code meanings:

| Exit code | Meaning |
|---|---|
| `0` | Plan succeeded and no changes are required |
| `1` | Terraform encountered an error |
| `2` | Plan succeeded and proposes changes |

### Review the saved plan

```bash
terraform -chdir=terraform/networking show \
  -no-color \
  network.tfplan
```

Review:

- Every resource action
- Resource counts
- CIDR blocks
- Availability Zones
- Routes
- NAT placement
- Endpoint route-table associations
- Encryption
- Retention
- Tags
- Any replacement or deletion

### Apply

Apply only the reviewed saved plan:

```bash
terraform -chdir=terraform/networking apply \
  network.tfplan
```

Using the saved plan ensures Terraform applies the same actions that were
reviewed.

### Confirm convergence

```bash
terraform -chdir=terraform/networking plan \
  -detailed-exitcode

PLAN_EXIT_CODE=$?
echo "Terraform plan exit code: $PLAN_EXIT_CODE"
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
Terraform plan exit code: 0
```

Convergence confirms that:

- Terraform configuration matches the remote state.
- Terraform state matches the refreshed AWS resource configuration.
- The apply did not leave a partial implementation.
- Provider-computed values do not cause persistent drift.
- The root is ready for downstream consumption.

## Inspect outputs

List all outputs:

```bash
terraform -chdir=terraform/networking output
```

Read one scalar output:

```bash
terraform -chdir=terraform/networking output \
  -raw vpc_id
```

Read an output as JSON:

```bash
terraform -chdir=terraform/networking output \
  -json private_application_subnet_ids_by_az
```

Important outputs include:

- `vpc_id`
- `vpc_arn`
- `vpc_cidr_block`
- `availability_zones`
- `public_subnet_ids`
- `public_subnet_ids_by_az`
- `private_application_subnet_ids`
- `private_application_subnet_ids_by_az`
- `private_data_subnet_ids`
- `private_data_subnet_ids_by_az`
- `internet_gateway_id`
- `nat_gateway_ids_by_az`
- `nat_gateway_public_ips_by_az`
- `public_route_table_id`
- `private_application_route_table_ids_by_az`
- `private_data_route_table_ids_by_az`
- `gateway_vpc_endpoint_ids`
- `vpc_flow_log_id`
- `vpc_flow_logs_log_group_name`
- `vpc_flow_logs_kms_key_arn`
- `default_security_group_id`

## Downstream state consumption

Future Terraform roots should consume networking outputs through remote state
or an explicitly approved shared-configuration mechanism.

Illustrative example:

```hcl
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket       = "avos-dev-tfstate-396913735153-us-east-2"
    key          = "network/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-2:396913735153:key/5dfe4f50-b095-4317-b7a8-28a8c21f7efe"
    use_lockfile = true
  }
}
```

A downstream EKS root could then reference:

```hcl
vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

subnet_ids = data.terraform_remote_state.networking.outputs.private_application_subnet_ids
```

Remote-state access grants visibility into the complete state snapshot, not
only declared outputs. Access to the state bucket must therefore remain
restricted.

## AWS validation commands

### VPC

```bash
aws ec2 describe-vpcs \
  --vpc-ids "$(terraform -chdir=terraform/networking output -raw vpc_id)" \
  --region us-east-2 \
  --profile avos-admin \
  --output table
```

### Subnets

```bash
AVOS_VPC_ID="$(
  terraform -chdir=terraform/networking output \
    -raw vpc_id
)"

aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$AVOS_VPC_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'sort_by(Subnets,&CidrBlock)[].{
    Name:Tags[?Key==`Name`]|[0].Value,
    SubnetId:SubnetId,
    AZ:AvailabilityZone,
    CIDR:CidrBlock,
    PublicIPv4OnLaunch:MapPublicIpOnLaunch,
    AvailableIPs:AvailableIpAddressCount
  }' \
  --output table
```

Expected subnet count:

```text
9
```

### NAT Gateways

```bash
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=$AVOS_VPC_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'NatGateways[].{
    NatGatewayId:NatGatewayId,
    State:State,
    SubnetId:SubnetId,
    PublicIp:NatGatewayAddresses[0].PublicIp
  }' \
  --output table
```

### Gateway endpoints

```bash
aws ec2 describe-vpc-endpoints \
  --filters \
    "Name=vpc-id,Values=$AVOS_VPC_ID" \
    "Name=vpc-endpoint-type,Values=Gateway" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'VpcEndpoints[].{
    EndpointId:VpcEndpointId,
    Service:ServiceName,
    Type:VpcEndpointType,
    State:State,
    RouteTableIds:RouteTableIds
  }' \
  --output json
```

Expected services:

```text
com.amazonaws.us-east-2.s3
com.amazonaws.us-east-2.dynamodb
```

### VPC Flow Logs

```bash
aws ec2 describe-flow-logs \
  --filter "Name=resource-id,Values=$AVOS_VPC_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'FlowLogs[].{
    FlowLogId:FlowLogId,
    ResourceId:ResourceId,
    TrafficType:TrafficType,
    DestinationType:LogDestinationType,
    Destination:LogDestination,
    Status:FlowLogStatus
  }' \
  --output table
```

### CloudWatch Logs

Git Bash can rewrite arguments beginning with `/`. Disable path conversion for
the log-group-name argument:

```bash
MSYS_NO_PATHCONV=1 aws logs describe-log-groups \
  --log-group-name-prefix "/aws/vpc/flow-logs/avos-dev" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'logGroups[].{
    Name:logGroupName,
    RetentionDays:retentionInDays,
    KmsKeyId:kmsKeyId,
    Class:logGroupClass,
    StoredBytes:storedBytes
  }' \
  --output table
```

Inspect recent streams:

```bash
MSYS_NO_PATHCONV=1 aws logs describe-log-streams \
  --log-group-name "/aws/vpc/flow-logs/avos-dev" \
  --order-by LastEventTime \
  --descending \
  --limit 10 \
  --region us-east-2 \
  --profile avos-admin \
  --output table
```

### Restricted default security group

```bash
AVOS_DEFAULT_SG_ID="$(
  terraform -chdir=terraform/networking output \
    -raw default_security_group_id
)"

aws ec2 describe-security-groups \
  --group-ids "$AVOS_DEFAULT_SG_ID" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'SecurityGroups[].{
    GroupId:GroupId,
    GroupName:GroupName,
    IngressRuleCount:length(IpPermissions),
    EgressRuleCount:length(IpPermissionsEgress),
    VpcId:VpcId
  }' \
  --output table
```

Expected:

```text
IngressRuleCount = 0
EgressRuleCount  = 0
```

## Repository safety

The following files must remain untracked:

- `backend.hcl`
- `terraform.tfvars`
- `.terraform/`
- `*.tfstate`
- `*.tfstate.*`
- `*.tfplan`

Check for tracked generated or sensitive artifacts:

```bash
git ls-files \
  | grep -E \
  '(^|/)(backend\.hcl|terraform\.tfvars|.*\.tfstate.*|.*\.tfplan)$' \
  && echo "FAIL: generated or sensitive Terraform artifacts are tracked" \
  || echo "PASS: no generated or sensitive Terraform artifacts are tracked"
```

Do not commit:

- AWS access keys
- SSO cache data
- Temporary credentials
- Secret values
- Local backend files
- Terraform state
- Saved Terraform plans

## Cost considerations

The primary recurring development costs in this root include:

- NAT Gateway hourly usage
- NAT Gateway data processing
- Public IPv4 address usage
- CloudWatch Logs ingestion and retention
- Customer-managed KMS key usage

S3 and DynamoDB Gateway endpoints do not have an hourly endpoint charge.

Cost controls in this design include:

- One development NAT Gateway
- A 30-day Flow Logs retention period
- Gateway endpoints for S3 and DynamoDB
- Deferred interface endpoints
- No unnecessary public IPv4 assignment

## Production evolution

Before promoting this design to production:

1. Use one NAT Gateway per Availability Zone.
2. Evaluate separate AWS accounts for staging and production.
3. Confirm non-overlapping VPC CIDR allocation across accounts and Regions.
4. Define workload-specific security groups.
5. Evaluate interface endpoints based on traffic and security requirements.
6. Define private DNS requirements.
7. Evaluate IPv6 support.
8. Evaluate centralized egress and inspection requirements.
9. Define longer-term Flow Logs retention and analytics.
10. Add automated Terraform tests and policy-as-code checks.

## Destruction warning

Destroying this root can remove foundational network resources used by
downstream platforms.

Before any destroy operation:

- Confirm no EKS cluster uses the subnets.
- Confirm no load balancer uses the subnets.
- Confirm no database or cache uses the data subnets.
- Confirm no network interface remains attached.
- Confirm downstream Terraform roots have been destroyed first.
- Review the complete destroy plan.
- Confirm state backups are available.

Never run `terraform destroy` casually against a shared or production
environment.

## Architecture decision record

The approved design and its tradeoffs are recorded in:

```text
Docs/ADR/ADR-003-avos-network-foundation.md
```