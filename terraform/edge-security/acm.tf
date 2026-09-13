# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.2 - TLS & DNS
# CloudFront ACM Certificate
#
# Purpose:
# Creates the us-east-1 ACM certificate that will terminate viewer HTTPS
# connections at CloudFront.
# =============================================================================

module "cloudfront_acm" {
  source = "../modules/cloudfront-acm"

  providers = {
    aws = aws.us_east_1
  }

  project_name = var.project_name
  environment  = var.environment

  domain_name = var.domain_name

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  route53_zone_id = var.route53_zone_id

  tags = var.tags
}