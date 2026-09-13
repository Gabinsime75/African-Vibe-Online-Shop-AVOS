# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront ACM
# Phase 7.2 - TLS & DNS
#
# Purpose:
# Creates and DNS-validates the public ACM certificate used by CloudFront for
# HTTPS viewer connections to the CloudHustler custom domain.
#
# IMPORTANT:
# CloudFront viewer certificates must exist in us-east-1. The calling root
# therefore passes the aliased us-east-1 AWS provider to this module.
# =============================================================================

# -----------------------------------------------------------------------------
# ACM Certificate
# -----------------------------------------------------------------------------

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name  = "${var.project_name}-${var.environment}-cloudfront-acm"
      Phase = "Edge-Security"
    }
  )
}

# -----------------------------------------------------------------------------
# Route 53 DNS Validation Records
# -----------------------------------------------------------------------------

resource "aws_route53_record" "validation" {
  for_each = {
    for option in aws_acm_certificate.this.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id = var.route53_zone_id

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]

  ttl = 60

  allow_overwrite = true
}

# -----------------------------------------------------------------------------
# ACM Certificate Validation
# -----------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}