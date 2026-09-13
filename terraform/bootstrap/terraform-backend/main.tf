# Bootstrap KMS Key
module "kms" {
  source                  = "../../modules/KMS"
  alias                   = "${var.project_name}-terraform-state"
  description             = "KMS key for Terraform remote state."
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = var.tags

}


# Bootstrap S3 Bucket
module "s3" {
  source      = "../../modules/S3"
  bucket_name = "${var.project_name}-tfstate-${var.environment}"
  # versioning_enabled = true
  kms_key_arn = module.kms.key_arn

  tags = var.tags

}

# 
# Bootstrap DynamoDB Lock Table
module "dynamodb" {
  source                         = "../../modules/DynamoDB"
  table_name                     = "${var.project_name}-terraform-locks"
  billing_mode                   = "PAY_PER_REQUEST"
  hash_key                       = "LockID"
  point_in_time_recovery_enabled = true
  deletion_protection_enabled    = true
  server_side_encryption_enabled = true
  kms_key_arn                    = module.kms.key_arn
  table_class                    = "STANDARD"

  tags = var.tags

}