## KMS Module Test---------------------------------------
# module "kms" {
#   source = "../modules/kms"
#   description             = "Enterprise Foundation Test KMS Key"
#   alias                   = "foundation-test"
#   enable_key_rotation     = true
#   multi_region            = false
#   deletion_window_in_days = 30

#   tags = {
#     Project     = "Enterprise Foundation"
#     Environment = "Test"
#     ManagedBy   = "Terraform"
#   }
# }

## S3 Module Test-----------------------------------------
# module "s3" {

#   source = "../modules/s3"

#   bucket_name = "cloudhustler-s3-module-test-001"

#   versioning_enabled = true

#   kms_key_arn = "arn:aws:kms:us-east-2:396913735153:key/414bda13-ddba-4616-a85d-289fce669e48"

#   force_destroy = true

#   enable_logging = false
#   logging_bucket = null
#   logging_prefix = "logs/"

#   lifecycle_enabled = true

#   noncurrent_version_expiration_days = 90

#   enable_public_access_block = true

#   enable_bucket_key = true

#   bucket_policy = null

#   tags = {

#     Name        = "cloudhustler-s3-module-test"
#     Environment = "Lab"
#     Project     = "CloudHustler"

#   }

# }


## DynamoDB Module Test-----------------------------------
# module "dynamodb" {

#   source = "../modules/dynamodb"

#   table_name   = "cloudhustler-terraform-locks-test"
#   billing_mode = "PAY_PER_REQUEST"

#   hash_key = "LockID"

#   point_in_time_recovery_enabled = true

#   deletion_protection_enabled = false

#   server_side_encryption_enabled = true

#   kms_key_arn = "arn:aws:kms:us-east-2:396913735153:key/414bda13-ddba-4616-a85d-289fce669e48"

#   table_class = "STANDARD"

#   tags = {

#     Name        = "cloudhustler-terraform-locks-test"
#     Environment = "Lab"
#     Project     = "CloudHustler"
#     ManagedBy   = "Terraform"
#   }
# }

## IAM Module Test-----------------------------------
# module "iam" {

#   source = "../modules/iam"


#   # Role
#   role_name        = "cloudhustler-ec2-role"
#   role_description = "IAM Role for CloudHustler EC2 instances"

#   # Trust Policy
#   trusted_services = [
#     "ec2.amazonaws.com"
#   ]

#   # IAM Policy
#   policy_name        = "cloudhustler-ec2-policy"
#   policy_description = "Policy for CloudHustler EC2 instances"

#   policy_document = jsonencode({

#     Version = "2012-10-17"

#     Statement = [

#       {

#         Effect = "Allow"

#         Action = [

#           "s3:ListBucket",
#           "s3:GetObject"

#         ]

#         Resource = "*"

#       }

#     ]

#   })


#   # Instance Profile
#   create_instance_profile = true

#   # Permission Boundary
#   create_permission_boundary = true

#   permission_boundary_name = "cloudhustler-permission-boundary"

#   permission_boundary_policy = jsonencode({

#     Version = "2012-10-17"

#     Statement = [

#       {

#         Effect = "Allow"

#         Action = "*"

#         Resource = "*"

#       }

#     ]

#   })

#   # Tags
#   tags = {

#     Project     = "CloudHustler"
#     Environment = "Test"

#   }

# }

## Organization Testing------------------------------------------
#############################################
# AWS Organization Test
# ##

## Governance Testing------------------------------------------

module "governance" {

  source                    = "../../terraform/governance"
  organization_id           = var.organization_id
  cloudtrail_s3_bucket_name = var.cloudtrail_s3_bucket_name
  cloudtrail_kms_key_arn    = var.cloudtrail_kms_key_arn
  config_s3_bucket_name     = var.config_s3_bucket_name
  config_service_role_arn   = var.config_service_role_arn

}