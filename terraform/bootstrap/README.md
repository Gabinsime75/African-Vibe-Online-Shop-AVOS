
# 🚀 Bootstrap Backend

The **Bootstrap Backend** is the foundation of the CloudHustler Commerce Platform infrastructure. It provisions the AWS resources required for Terraform to securely manage infrastructure using a remote backend. Once deployed, every Terraform root module shares the same backend for centralized state management, encryption, and state locking.

## 🎯 Purpose

The bootstrap deployment provisions the foundational AWS resources required before any other Terraform infrastructure can be deployed.

It creates:

- **AWS KMS Customer-Managed Key**
  - Encrypts Terraform state stored in Amazon S3.
  - Supports automatic key rotation.
  - Provides customer-managed encryption for state files.

- **Amazon S3 Bucket**
  - Stores Terraform remote state files.
  - Versioning enabled.
  - Server-side encryption enabled.
  - Public access blocked.
  - Lifecycle rules supported.

- **Amazon DynamoDB Table**
  - Provides Terraform state locking.
  - Uses PAY_PER_REQUEST billing mode.
  - Supports Point-in-Time Recovery (PITR).
  - Supports server-side encryption.

## ❓ Why is a Bootstrap Deployment Needed?

Terraform cannot use a remote backend until the backend infrastructure already exists.

This creates a dependency problem:

- Terraform requires an Amazon S3 bucket before it can store its state remotely.
- Terraform requires an Amazon DynamoDB table before it can lock the Terraform state.
- Terraform cannot create these resources while simultaneously using them as its backend.

The bootstrap deployment solves this problem by using a temporary local state to provision the backend resources. Once deployed, Terraform migrates the local state to the remote backend, allowing every future deployment to use centralized state management.

## 🚀 Deployment Steps

### 1. Navigate to the Bootstrap Directory

```
cd infrastructure/terraform/bootstrap/backend
```

### 2. Initialize Terraform

```bash
terraform init
```

Terraform downloads the required providers and initializes the working directory.

### 3. Review the Execution Plan

```bash
terraform plan
```

Review the resources that Terraform will create before applying any changes.

### 4. Deploy the Bootstrap Infrastructure

```
terraform apply
```

Approve the deployment when prompted.

Terraform will provision:

- AWS KMS Key
- Amazon S3 Bucket
- Amazon DynamoDB Table

### 5. Verify the Deployment

```
terraform output
```

Verify that Terraform returns the expected outputs.

## 🔄 Backend Migration

After the bootstrap deployment completes successfully, every Terraform root module should be configured to use the shared remote backend.

Example `backend.tf`:

```  
terraform {

  backend "s3" {

    bucket         = "cloudhustler-tfstate-prod"
    key            = "organization/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "cloudhustler-terraform-locks"
    encrypt        = true

  }

}
```

Reinitialize Terraform:

```
terraform init
```

Terraform will detect the backend configuration change and prompt to migrate the existing local state.

Approve the migration when prompted.

Once completed, Terraform will store all future state files in the remote backend.

## 📤 Outputs

The bootstrap deployment exports the following outputs:

- **kms_key_arn**
  - ARN of the customer-managed KMS key.

- **s3_bucket_name**
  - Name of the Terraform remote state bucket.

- **dynamodb_table_name**
  - Name of the Terraform state locking table.

These outputs can be referenced by automation pipelines or other infrastructure components if needed.



## 🛠️ Common Troubleshooting

### BucketAlreadyOwnedByYou

**Cause**

The Amazon S3 bucket already exists within your AWS account, but Terraform is not currently managing it.

**Solution**

Import the bucket into the Terraform state.

```
terraform import module.s3.aws_s3_bucket.s3_bucket <bucket-name>
```

### Resource Already Exists

**Cause**

The resource was previously created manually or the Terraform state file was lost.

**Solution**

Import the existing resource into Terraform.

```
terraform import <resource-address> <resource-id>
```

### State Lock Error

**Cause**

Another Terraform operation currently holds the DynamoDB state lock.

**Solution**

Wait for the current operation to complete or remove the stale lock.

```
terraform force-unlock <LOCK_ID>
```

### Access Denied

Verify that the IAM principal has permissions for:

- Amazon S3
- AWS KMS
- Amazon DynamoDB
- AWS IAM
- AWS STS

## 🌐 Consuming the Backend

Once the bootstrap deployment has been completed, every Terraform root module should use the shared backend.

Examples include:

- Organization
- Governance
- Identity
- Networking
- Security
- Observability
- Environments

Each root module should maintain its own Terraform state file while sharing the same backend infrastructure.

Example state files:

- `organization/terraform.tfstate`
- `governance/terraform.tfstate`
- `identity/terraform.tfstate`
- `networking/terraform.tfstate`
- `security/terraform.tfstate`
- `observability/terraform.tfstate`
- `environments/dev/terraform.tfstate`
- `environments/staging/terraform.tfstate`
- `environments/prod/terraform.tfstate`

Benefits include:

- Independent deployments.
- Centralized state management.
- Secure state locking.
- KMS encryption.
- Versioned state history.
- Safe collaboration across engineering teams.

