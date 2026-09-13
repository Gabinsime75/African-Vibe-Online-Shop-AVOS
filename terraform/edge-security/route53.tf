# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.2.3 - Public DNS Cutover
#
# Purpose:
# Routes the public CloudHustler domain names to the CloudFront distribution.
#
# Ownership:
#   networking/
#     origin.cloudhusller.com -> ALB
#
#   edge-security/
#     cloudhusller.com        -> CloudFront
#     www.cloudhusller.com    -> CloudFront
# =============================================================================

resource "aws_route53_record" "apex" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = module.cloudfront.domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = module.cloudfront.domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}