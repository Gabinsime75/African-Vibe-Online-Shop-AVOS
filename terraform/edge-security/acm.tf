# =============================================================================
# AVOS Phase 7 — CloudFront and ALB HTTPS certificates
# =============================================================================

provider "aws" {
  alias               = "us_east_1"
  region              = "us-east-1"
  allowed_account_ids = ["396913735153"]

  default_tags {
    tags = {
      Project       = "AVOS"
      Environment   = "dev"
      ManagedBy     = "Terraform"
      TerraformRoot = "edge-security"
    }
  }
}

resource "aws_acm_certificate" "viewer" {
  provider          = aws.us_east_1
  domain_name       = "shop.avos-dev.cloudhusller.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "origin" {
  domain_name       = "origin.avos-dev.cloudhusller.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    viewer = aws_acm_certificate.viewer.domain_validation_options
    origin = aws_acm_certificate.origin.domain_validation_options
  }

  zone_id = aws_route53_zone.avos.zone_id
  name    = one(each.value).resource_record_name
  type    = one(each.value).resource_record_type
  records = [one(each.value).resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "viewer" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.viewer.arn
  validation_record_fqdns = [aws_route53_record.acm_validation["viewer"].fqdn]

  timeouts {
    create = "15m"
  }
}

resource "aws_acm_certificate_validation" "origin" {
  certificate_arn         = aws_acm_certificate.origin.arn
  validation_record_fqdns = [aws_route53_record.acm_validation["origin"].fqdn]

  timeouts {
    create = "15m"
  }
}

output "viewer_certificate_arn" {
  value = aws_acm_certificate_validation.viewer.certificate_arn
}

output "origin_certificate_arn" {
  value = aws_acm_certificate_validation.origin.certificate_arn
}
