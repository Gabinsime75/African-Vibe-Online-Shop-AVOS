````markdown
# 🏢 AWS Organization

The **AWS Organization** deployment establishes the multi-account foundation for the CloudHustler Commerce Platform. It creates the AWS Organization, enables Service Control Policies (SCPs), and provisions Organizational Units (OUs) to logically separate workloads, enforce governance, and improve security across multiple AWS accounts.


## 🎯 Purpose

- **Manages an existing AWS Organization by provisioning:**
  - Organizational Units (OUs).
  - Service Control Policies (SCPs).
  - Policy Attachments.

The Organization deployment provides centralized governance for the AWS environment before any application infrastructure is deployed.

It creates:

- **AWS Organization**
  - Centralized account management.
  - Consolidated billing.
  - Central governance.

- **Service Control Policies (SCPs)**
  - Restrict unauthorized AWS actions.
  - Enforce security guardrails.
  - Standardize governance across accounts.

- **Organizational Units (OUs)**
  - Security
  - Infrastructure
  - NonProduction
  - Production

These Organizational Units provide logical separation of workloads while allowing centralized policy management.


## ✨ Features

- AWS Organization creation.
- All features enabled.
- Service Control Policies (SCPs).
- Organizational Unit creation.
- SCP attachment support.
- Centralized governance.
- Multi-account architecture.
- Environment isolation.
- Enterprise-ready foundation.


## 🏗️ Resources Created

Depending on the deployment, Terraform provisions:

- `aws_organizations_organization`
- `aws_organizations_organizational_unit`
- `aws_organizations_policy`
- `aws_organizations_policy_attachment`


## 📂 Directory Structure

```text
organization/
├── organization.tf
├── organizational_units.tf
├── service_control_policies.tf
├── policy_attachments.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── locals.tf
├── outputs.tf
└── README.md
```


## 🏛️ Organizational Structure

```text
Root
├── Security
├── Infrastructure
├── NonProduction
└── Production
```

---

## 🔒 Service Control Policies

The Organization deployment supports attaching Service Control Policies to Organizational Units.

Typical examples include:

- Deny Root User Access Keys
- Restrict Unsupported AWS Regions
- Require Encryption
- Prevent Public S3 Buckets
- Protect CloudTrail
- Protect AWS Config
- Restrict IAM Privilege Escalation
- Restrict Account Closure

These policies provide preventive security controls across the organization.


## 🚀 Deployment Steps

### 1. Navigate to the Organization Directory

```
cd infrastructure/terraform/organization
```

### 2. Initialize Terraform

```
terraform init
```

Terraform downloads the required providers and configures the remote backend.

### 3. Review the Deployment Plan

```
terraform plan
```

Review the AWS Organization resources before deployment.

### 4. Deploy the Organization

```
terraform apply
```

Approve the deployment when prompted.

Terraform will provision:

- AWS Organization
- Organizational Units
- Service Control Policies
- Policy Attachments

### 5. Verify the Deployment

```
terraform output
```

Verify that all Organizational Units and Service Control Policies were created successfully.


## 📥 Inputs

| Name | Description |
|------|-------------|
| `organization_feature_set` | AWS Organization feature set |
| `organizational_units` | List of Organizational Units |
| `service_control_policies` | SCP definitions |
| `tags` | Resource tags |



## 📤 Outputs

The deployment exports the following outputs:

- **organization_id**
  - AWS Organization ID.

- **root_id**
  - Root Organizational Unit ID.

- **security_ou_id**
  - Security OU ID.

- **infrastructure_ou_id**
  - Infrastructure OU ID.

- **nonproduction_ou_id**
  - NonProduction OU ID.

- **production_ou_id**
  - Production OU ID.

- **scp_ids**
  - IDs of all Service Control Policies.


## 🛠️ Common Troubleshooting

### Organization Already Exists

**Cause**

Only one AWS Organization can exist per management account.

**Solution**

Import the existing Organization into Terraform or deploy from a new management account.


### SCP Attachment Failed

**Cause**

The Organizational Unit may not exist or the policy was not created successfully.

**Solution**

Verify that the Organizational Unit IDs and SCP IDs are correct before applying Terraform.


### Access Denied

Verify that the IAM principal has permissions for:

- AWS Organizations
- AWS IAM
- AWS STS


### Policy Already Exists

**Cause**

An SCP with the same name already exists.

**Solution**

Import the existing policy into Terraform or rename the policy.


## 🌐 Integration with the Platform

The Organization deployment serves as the governance layer for every environment within the CloudHustler Commerce Platform.

Future Terraform deployments will provision resources into accounts organized under these Organizational Units, including:

- Governance
- Identity
- Networking
- Security
- Observability
- Shared Services
- Development
- Staging
- Production

This structure provides consistent governance and simplifies account management as the platform grows.


## 🔒 Best Practices

- Enable **All Features** when creating the AWS Organization.
- Apply Service Control Policies at the Organizational Unit level whenever possible.
- Separate production and non-production workloads.
- Place shared infrastructure in a dedicated Infrastructure OU.
- Isolate security tooling in a dedicated Security OU.
- Keep SCPs simple, focused, and well documented.
- Test SCPs in NonProduction before applying them to Production.
- Follow the principle of least privilege for IAM permissions.
- Manage the entire AWS Organization through Terraform.


## 🎯 Next Steps

With the AWS Organization deployed, the CloudHustler Commerce Platform is ready to continue building its enterprise foundation.

The recommended next deployments are:

1. Governance
2. Identity
3. Networking
4. Security
5. Observability
6. Environments
7. Platform Services
8. Application Infrastructure

This Organization deployment provides the governance framework that all future AWS accounts and infrastructure will inherit.
````
