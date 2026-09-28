# =============================================================================
# AVOS Security Outputs
#
# Exposes non-sensitive identifiers required by later infrastructure and
# application phases. No credentials or secret values are returned.
# =============================================================================

output "guardduty_detector_id" {
  description = "ID of the AVOS GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}

output "guardduty_feature_statuses" {
  description = "Configured status of each Terraform-managed GuardDuty feature."
  value       = local.guardduty_detector_features
}

output "securityhub_account_id" {
  description = "Account identifier associated with the regional Security Hub."
  value       = aws_securityhub_account.this.id
}

output "securityhub_standard_subscription_ids" {
  description = "Security Hub standard subscription identifiers."
  value = {
    for name, subscription in aws_securityhub_standards_subscription.this :
    name => subscription.id
  }
}

output "detective_graph_arn" {
  description = "ARN of the AVOS Detective behavior graph."
  value       = aws_detective_graph.this.id
}

output "access_analyzer_arn" {
  description = "ARN of the AVOS external-access analyzer."
  value       = aws_accessanalyzer_analyzer.external_access.arn
}

output "secrets_kms_key_id" {
  description = "ID of the customer-managed KMS key for AVOS secrets."
  value       = aws_kms_key.secrets.key_id
}

output "secrets_kms_key_arn" {
  description = "ARN of the customer-managed KMS key for AVOS secrets."
  value       = aws_kms_key.secrets.arn
}

output "secrets_kms_alias" {
  description = "Alias of the customer-managed KMS key for AVOS secrets."
  value       = aws_kms_alias.secrets.name
}