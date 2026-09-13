````markdown
# 🔐 Identity

The **Identity** deployment establishes the identity and access management foundation for the CloudHustler Commerce Platform. It provisions reusable IAM roles, policies, instance profiles, permission boundaries, and service roles that enable AWS services, applications, and infrastructure to securely interact while enforcing the principle of least privilege.


## 🎯 Purpose

The Identity deployment provisions the AWS Identity and Access Management (IAM) resources required to securely operate the CloudHustler Commerce Platform.

It creates:

- **IAM Roles**
  - Service roles.
  - Application roles.
  - Infrastructure roles.
  - Cross-service roles.

- **IAM Policies**
  - Customer-managed IAM policies.
  - Least-privilege permissions.
  - Reusable policy documents.

- **IAM Instance Profiles**
  - EC2 instance profiles.
  - Secure role attachment for EC2 instances.

- **Permission Boundaries**
  - Maximum permission limits.
  - Delegated administration.
  - Enterprise governance.

- **AWS Service Roles**
  - AWS Config.
  - AWS CloudTrail.
  - Amazon GuardDuty.
  - AWS Security Hub.
  - Future AWS services.


## ✨ Features

- Centralized identity management.
- Reusable IAM modules.
- Least-privilege access control.
- Service role provisioning.
- Permission boundary support.
- EC2 instance profile support.
- Customer-managed IAM policies.
- Environment-agnostic design.
- Enterprise-ready security.

## 🏗️ Resources Created

The Identity deployment provisions reusable IAM resources including:

- IAM Roles
- IAM Policies
- IAM Role Policy Attachments
- IAM Instance Profiles
- Permission Boundaries
- AWS Service Roles

These resources provide the authentication and authorization layer used throughout the platform.

## 📂 Directory Structure

```text
identity/
├── versions.tf
├── providers.tf
├── backend.tf
├── variables.tf
├── locals.tf
├── iam.tf
├── service_roles.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```


## 🏛️ Identity Architecture

```text
Identity
│
├── IAM Roles
│
├── IAM Policies
│
├── Permission Boundaries
│
├── Instance Profiles
│
└── AWS Service Roles
    ├── AWS Config
    ├── AWS CloudTrail
    ├── Amazon GuardDuty
    └── AWS Security Hub
```


## 🚀 Deployment Steps

### 1. Navigate to the Identity Directory

```bash
cd infrastructure/terraform/identity
```

### 2. Initialize Terraform

```bash
terraform init
```

Terraform downloads the required providers and configures the remote backend.

### 3. Review the Deployment Plan

```bash
terraform plan
```

Review the IAM resources before deployment.

### 4. Deploy the Identity Infrastructure

```bash
terraform apply
```

Approve the deployment when prompted.

Terraform provisions:

- IAM Roles
- IAM Policies
- IAM Instance Profiles
- Permission Boundaries
- AWS Service Roles

### 5. Verify the Deployment

```bash
terraform output
```

Verify that all IAM resources were created successfully.


## 📦 Modules Used

The Identity deployment consumes the following reusable Terraform modules:

- IAM Module
- Config Service Role Module
- CloudTrail Service Role Module
- GuardDuty Service Role Module
- Security Hub Service Role Module

These modules provide standardized IAM resources that can be reused throughout the platform.


## 📥 Inputs

| Name | Description |
|------|-------------|
| `environment` | Deployment environment |
| `project_name` | Project name |
| `permission_boundary_arn` | Permission boundary ARN |
| `create_instance_profiles` | Enable EC2 instance profiles |
| `service_roles` | Service role configuration |
| `tags` | Resource tags |


## 📤 Outputs

The deployment exports the following outputs:

- **iam_role_arns**
  - ARNs of all IAM roles.

- **iam_policy_arns**
  - ARNs of all customer-managed IAM policies.

- **instance_profile_arns**
  - ARNs of all EC2 instance profiles.

- **service_role_arns**
  - ARNs of all AWS service roles.


## 🔒 Security Best Practices

The Identity deployment follows AWS security best practices by:

- Enforcing the Principle of Least Privilege.
- Using IAM Roles instead of long-lived IAM Users.
- Creating customer-managed IAM policies.
- Separating trust policies from permission policies.
- Supporting permission boundaries.
- Applying consistent resource tagging.
- Avoiding wildcard permissions whenever possible.
- Creating dedicated roles for AWS services.
- Reusing standardized IAM modules across the platform.


## 🛠️ Common Troubleshooting

### IAM Role Already Exists

**Cause**

An IAM role with the same name already exists.

**Solution**

Import the existing role into Terraform or rename the role.


### IAM Policy Already Exists

**Cause**

A customer-managed policy with the same name already exists.

**Solution**

Import the existing policy into Terraform or use a unique policy name.


### Permission Boundary Not Found

**Cause**

The specified permission boundary ARN does not exist.

**Solution**

Verify the ARN or deploy the permission boundary before referencing it.


### Access Denied

Verify that the IAM principal has permissions for:

- AWS IAM
- AWS STS


## 🌐 Integration with the Platform

The Identity deployment provides the authentication and authorization layer for every CloudHustler Commerce Platform component.

Future deployments that consume these IAM resources include:

- Networking
- Security
- Observability
- Amazon EKS
- Amazon ECS
- AWS Lambda
- Amazon RDS
- Amazon ElastiCache
- Amazon OpenSearch
- GitHub Actions
- CI/CD Pipelines

Every infrastructure component inherits standardized identity management through reusable IAM modules.


## 🔒 Best Practices

- Create one IAM role per workload.
- Use customer-managed IAM policies.
- Separate trust policies from permission policies.
- Apply permission boundaries where appropriate.
- Prefer IAM Roles over IAM Users.
- Rotate credentials automatically whenever possible.
- Avoid wildcard permissions unless absolutely necessary.
- Tag IAM resources consistently.
- Reuse IAM modules across every deployment.
- Manage all IAM resources through Terraform.


## 🎯 Next Steps

With the Identity layer deployed, the CloudHustler Commerce Platform has a secure and standardized identity foundation for every AWS workload.

The recommended next deployments are:

1. Networking
2. Security
3. Observability
4. Environments
5. Platform Services
6. Application Infrastructure

The Identity deployment provides the authentication and authorization foundation that every future infrastructure and application component will rely upon.
````
