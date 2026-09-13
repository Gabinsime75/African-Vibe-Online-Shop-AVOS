# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront ACM
# Outputs
# =============================================================================

output "certificate_arn" {
  description = "ARN of the validated CloudFront ACM certificate."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_name" {
  description = "Primary domain name of the CloudFront certificate."
  value       = aws_acm_certificate.this.domain_name
}