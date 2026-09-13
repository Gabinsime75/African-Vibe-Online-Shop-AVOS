output "kms_key_arn" {
  description = "ARN of the KMS key."
  value       = module.kms.key_arn
}

output "terraform_state_bucket" {
  description = "Terraform state bucket."
  value       = module.s3.bucket_name
}

output "terraform_lock_table" {
  description = "Terraform state lock table."
  value       = module.dynamodb.table_name
}