# =============================================================================
# AVOS Terraform Bootstrap — Outputs
#
# Exposes the safe identifiers required to verify the state foundation and
# configure the S3 backend after the initial local-state deployment.
# =============================================================================

output "aws_account_id" {
  description = "AWS account that owns the AVOS Terraform state foundation."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region containing the AVOS Terraform state foundation."
  value       = var.aws_region
}

output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket storing AVOS Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket storing AVOS Terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "ARN of the customer-managed KMS key encrypting Terraform state."
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_kms_alias" {
  description = "Human-readable alias assigned to the Terraform state KMS key."
  value       = aws_kms_alias.terraform_state.name
}

output "bootstrap_state_key" {
  description = "Canonical S3 object key used for the bootstrap root state."
  value       = local.bootstrap_state_key
}

output "backend_configuration" {
  description = "Values required to configure and migrate the bootstrap S3 backend."

  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    key          = local.bootstrap_state_key
    region       = var.aws_region
    encrypt      = true
    kms_key_id   = aws_kms_key.terraform_state.arn
    use_lockfile = true
  }
}