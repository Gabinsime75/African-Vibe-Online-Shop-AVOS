# Create a customer-managed symmetric KMS key.
# Used to encrypt AWS resources across the platform.
###############################################
resource "aws_kms_key" "kms_key" {

  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days

  multi_region             = var.multi_region
  is_enabled               = var.is_enabled
  customer_master_key_spec = var.customer_master_key_spec

  tags = var.tags

}

###############################################
# Create a friendly alias for the KMS key.
# Allows AWS services to reference the key by name.
###############################################
resource "aws_kms_alias" "this" {

  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.kms_key.id

}