# DynamoDB Table
resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {

    name = var.hash_key
    type = "S"
  }

  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  # Server Side Encryption
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  # Point-In-Time Recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  tags = var.tags
}

## Example for Terraform remote state locking
# module "terraform_locks" {

#   source = "../modules/dynamodb"

#   table_name  = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   point_in_time_recovery_enabled = true
#   server_side_encryption_enabled = true
#   deletion_protection_enabled    = true

#   kms_key_arn = module.kms.kms_key_arn

#   table_class = "STANDARD"

#   tags = {
#     Name        = "terraform-locks"
#     Environment = "Production"
#     ManagedBy   = "Terraform"
#   }

# }