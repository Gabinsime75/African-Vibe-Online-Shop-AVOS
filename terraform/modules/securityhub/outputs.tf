output "securityhub_account_id" {
  description = "Security Hub account ID."
  value       = aws_securityhub_account.this.id
}

output "securityhub_arn" {
  description = "Security Hub ARN."
  value       = aws_securityhub_account.this.arn
}

output "fsbp_enabled" {
  description = "Whether AWS Foundational Security Best Practices are enabled."
  value       = var.enable_fsbp_standard
}