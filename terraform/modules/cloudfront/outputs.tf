# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront
# Outputs
#
# Purpose:
# Exposes CloudFront identifiers and endpoints needed for validation and later
# Phase 7 integrations such as Route 53, ACM, WAF, and monitoring.
# =============================================================================

output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "CloudFront-generated distribution domain."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront hosted zone ID for Route 53 aliases."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "status" {
  description = "CloudFront distribution status."
  value       = aws_cloudfront_distribution.this.status
}