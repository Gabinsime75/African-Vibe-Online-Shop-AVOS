# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7 - CloudFront WAF Outputs
# =============================================================================

output "web_acl_id" {
  description = "ID of the CloudFront WAF Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "ARN of the CloudFront WAF Web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "Name of the CloudFront WAF Web ACL."
  value       = aws_wafv2_web_acl.this.name
}