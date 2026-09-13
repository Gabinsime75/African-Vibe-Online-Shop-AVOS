````markdown
# 🔐 IAM Module

The **IAM Module** provisions reusable AWS Identity and Access Management (IAM) resources for the CloudHustler Commerce Platform. It provides a standardized way to create IAM roles, policies, trust relationships, permission boundaries, and instance profiles while following security best practices and the principle of least privilege.


## 🎯 Purpose

The IAM module provides reusable building blocks for managing AWS identities and permissions across the platform.

It supports:

- **IAM Roles**
  - Service roles.
  - Cross-service roles.
  - Application roles.
  - Infrastructure roles.

- **IAM Policies**
  - Customer-managed IAM policies.
  - Inline policy documents.
  - JSON policy support.

- **Trust Policies**
  - Service trust relationships.
  - Cross-account trust.
  - Federated identities.

- **Permission Boundaries**
  - Maximum permission limits.
  - Enterprise governance.
  - Least privilege enforcement.

- **Instance Profiles**
  - EC2 Instance Profiles.
  - Role attachment for EC2 instances.


## ✨ Features

- Reusable Terraform module.
- Customer-managed IAM policies.
- IAM role creation.
- Trust policy support.
- Permission boundary support.
- EC2 instance profile creation.
- Policy attachment support.
- Least privilege design.
- Environment-agnostic.
- Tag support.


## 🧩 Policy Management Scenarios

The IAM module supports three common policy management patterns, making it flexible enough for application roles, infrastructure roles, and AWS service roles.

| Scenario | Variable Used |
|----------|---------------|
| Create a customer-managed IAM policy | `policy_document` |
| Attach one or more existing AWS-managed IAM policies | `managed_policy_arns` |
| Attach one or more existing customer-managed IAM policies | `managed_policy_arns` |

### ✅ Why this is a good design

This approach provides a single reusable IAM module that supports multiple use cases while preserving backward compatibility.

Benefits include:

- Create custom IAM policies when application-specific permissions are required.
- Reuse AWS-managed policies for AWS service roles.
- Attach existing customer-managed policies shared across multiple roles.
- Avoid duplicating IAM policies throughout the platform.
- Keep IAM roles lightweight and reusable.
- Reduce maintenance by leveraging AWS-managed policy updates.
- Support both simple and enterprise-scale IAM deployments.

## 🏗️ Resources Created

Depending on the module configuration, Terraform may provision:

- `aws_iam_role`
- `aws_iam_policy`
- `aws_iam_role_policy_attachment`
- `aws_iam_instance_profile`


## 📂 Module Structure

```text
modules/
└── iam/
    ├── role.tf
    ├── policy.tf
    ├── trust_policy.tf
    ├── permission_boundary.tf
    ├── instance_profile.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```


## 🚀 Example Usage

```hcl
module "iam" {

  source = "../../modules/iam"

  role_name               = "ec2-role"
  create_policy           = true
  policy_name             = "ec2-policy"
  create_instance_profile = true

  assume_role_services = [
    "ec2.amazonaws.com"
  ]

  policy_document = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "*"

      }

    ]

  })

  tags = {

    Environment = "prod"
    Project     = "CloudHustler"

  }

}
```


## 📥 Inputs

| Name | Description |
|------|-------------|
| `role_name` | Name of the IAM role |
| `description` | IAM role description |
| `policy_name` | Name of the IAM policy |
| `policy_document` | JSON IAM policy document |
| `assume_role_services` | List of AWS services allowed to assume the role |
| `permission_boundary_arn` | ARN of the permission boundary |
| `create_policy` | Create an IAM policy |
| `create_instance_profile` | Create an EC2 instance profile |
| `path` | IAM resource path |
| `tags` | Resource tags |


## 📤 Outputs

The module exports the following outputs:

- **role_name**
  - Name of the IAM role.

- **role_arn**
  - ARN of the IAM role.

- **policy_name**
  - Name of the IAM policy.

- **policy_arn**
  - ARN of the IAM policy.

- **instance_profile_name**
  - Name of the EC2 instance profile.

- **instance_profile_arn**
  - ARN of the EC2 instance profile.


## 🔒 Security Best Practices

This module follows AWS security best practices by:

- Applying the Principle of Least Privilege.
- Supporting customer-managed IAM policies.
- Separating trust policies from permission policies.
- Supporting permission boundaries.
- Avoiding wildcard permissions whenever possible.
- Supporting reusable policy documents.
- Allowing environment-specific tagging.
- Encouraging role-based access instead of long-lived IAM users.



## 🛠️ Common Use Cases

This module can be used to create:

- EC2 IAM Roles
- Lambda Execution Roles
- ECS Task Roles
- EKS Node Roles
- EKS IRSA Roles
- CI/CD Pipeline Roles
- GitHub Actions OIDC Roles
- CodeBuild Roles
- CodePipeline Roles
- Cross-Account IAM Roles



## 📖 Terraform Workflow

Initialize Terraform:

```
terraform init
```

Review the execution plan:

```
terraform plan
```

Deploy the resources:

```
terraform apply
```

View the outputs:

```
terraform output
```


## 📌 Best Practices

- Create one role per workload.
- Grant only the permissions required.
- Prefer managed policies over inline policies when possible.
- Separate trust policies from permission policies.
- Use permission boundaries for delegated administration.
- Avoid using `"Resource": "*"` unless absolutely necessary.
- Prefer IAM Roles over IAM Users.
- Tag IAM resources consistently across environments.
- Reuse this module throughout the platform for standardized IAM management.


## 🎯 Next Steps

This IAM module serves as the identity foundation for the CloudHustler Commerce Platform. It will be reused by future Terraform root modules including:

- Organization
- Governance
- Networking
- Security
- Observability
- EKS
- ECS
- Lambda
- RDS
- CI/CD Pipelines
- Application Services

By centralizing IAM resource creation into a reusable module, the platform maintains consistent security, governance, and access control across all AWS environments.
````
