# =============================================================================
# CloudHustler Commerce Platform
# Phase 7 - Edge & Security
# 7.1 CloudFront Foundation
#
# Purpose:
# Instantiates the reusable CloudFront module and configures the existing public
# Application Load Balancer as the CloudFront origin.
# =============================================================================

module "cloudfront" {
  source = "../modules/cloudfront"

  project_name = var.project_name
  environment  = var.environment

  alb_dns_name = "origin.${var.domain_name}"

  origin_id = "${var.project_name}-${var.environment}-alb-origin"

  price_class = var.cloudfront_price_class

  aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  acm_certificate_arn = module.cloudfront_acm.certificate_arn

  default_cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
  static_cache_policy_id  = data.aws_cloudfront_cache_policy.caching_optimized.id

  default_origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  static_origin_request_policy_id  = data.aws_cloudfront_origin_request_policy.all_viewer.id

  default_response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  static_response_headers_policy_id  = aws_cloudfront_response_headers_policy.security_headers.id

  web_acl_id = module.cloudfront_waf.web_acl_arn

  tags = var.tags

} 