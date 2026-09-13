# =============================================================================
# CloudHustler Commerce Platform
# Phase 7 - Edge & Security
# Outputs
# =============================================================================

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront-generated domain used for Phase 7.1 validation."
  value       = module.cloudfront.domain_name
}

output "cloudfront_status" {
  description = "CloudFront distribution deployment status."
  value       = module.cloudfront.status
}