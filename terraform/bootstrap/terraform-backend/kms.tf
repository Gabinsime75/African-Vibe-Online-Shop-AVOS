# =============================================================================
# AVOS Terraform Bootstrap — KMS Encryption
#
# Creates the customer-managed KMS key used to encrypt AVOS Terraform state.
# =============================================================================

resource "aws_kms_key" "terraform_state" {
  description = "Encrypts AVOS ${var.environment} Terraform state."

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false

  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  tags = {
    Name = "${local.name_prefix}-terraform-state"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${local.name_prefix}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}