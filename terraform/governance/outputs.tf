# =============================================================================
# AVOS Governance — Outputs
# =============================================================================

output "audit_log_bucket_name" {
  description = "Name of the protected S3 bucket containing governance evidence."
  value       = aws_s3_bucket.audit_logs.id
}

output "audit_log_bucket_arn" {
  description = "ARN of the protected governance evidence bucket."
  value       = aws_s3_bucket.audit_logs.arn
}

output "audit_kms_key_arn" {
  description = "ARN of the KMS key encrypting CloudTrail and AWS Config evidence."
  value       = aws_kms_key.audit_logs.arn
}

output "audit_kms_alias" {
  description = "Alias of the governance audit-log KMS key."
  value       = aws_kms_alias.audit_logs.name
}

output "cloudtrail_name" {
  description = "Name of the AVOS multi-Region management trail."
  value       = aws_cloudtrail.management.name
}

output "cloudtrail_arn" {
  description = "ARN of the AVOS multi-Region management trail."
  value       = aws_cloudtrail.management.arn
}

output "config_recorder_name" {
  description = "Name of the AVOS AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "config_delivery_channel_name" {
  description = "Name of the encrypted AWS Config delivery channel."
  value       = aws_config_delivery_channel.this.name
}