# =============================================================================
# AVOS Phase 7 — CloudFront, WAF, storefront DNS, and WAF logging
# =============================================================================

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_https" {
  security_group_id = aws_security_group.alb.id
  description       = "CloudFront HTTPS to ALB"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

data "aws_cloudfront_cache_policy" "dynamic" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "application" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_response_headers_policy" "security" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_wafv2_web_acl" "edge" {
  provider = aws.us_east_1
  name     = "avos-dev-edge"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = {
      common = {
        priority = 10
        name     = "AWSManagedRulesCommonRuleSet"
      }
      known_bad = {
        priority = 20
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
      }
      reputation = {
        priority = 30
        name     = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    content {
      name     = rule.key
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = rule.value.name
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = false
        metric_name                = "avos-dev-${rule.key}"
      }
    }
  }

  rule {
    name     = "rate-limit"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "IP"
        limit                 = 2000
        evaluation_window_sec = 300
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = false
      metric_name                = "avos-dev-rate-limit"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = false
    metric_name                = "avos-dev-edge"
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  provider          = aws.us_east_1
  name              = "aws-waf-logs-avos-dev-edge"
  retention_in_days = 14
}

resource "aws_wafv2_web_acl_logging_configuration" "edge" {
  provider                = aws.us_east_1
  resource_arn            = aws_wafv2_web_acl.edge.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}

resource "aws_cloudfront_distribution" "storefront" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "AVOS development storefront"
  aliases             = ["shop.avos-dev.cloudhusller.com"]
  price_class         = "PriceClass_100"
  http_version        = "http2and3"
  web_acl_id          = aws_wafv2_web_acl.edge.arn
  wait_for_deployment = true

  origin {
    domain_name = aws_route53_record.origin.fqdn
    origin_id   = "avos-alb"

    custom_header {
      name  = "X-AVOS-Origin-Key"
      value = var.origin_verification_secret
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id           = "avos-alb"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.dynamic.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.application.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.viewer.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [
    aws_lb_listener.https,
    aws_vpc_security_group_ingress_rule.cloudfront_https
  ]
}

resource "aws_route53_record" "storefront" {
  for_each = toset(["A", "AAAA"])

  zone_id = aws_route53_zone.avos.zone_id
  name    = "shop.avos-dev.cloudhusller.com"
  type    = each.value

  alias {
    name                   = aws_cloudfront_distribution.storefront.domain_name
    zone_id                = aws_cloudfront_distribution.storefront.hosted_zone_id
    evaluate_target_health = false
  }
}

output "storefront_url" {
  value = "https://shop.avos-dev.cloudhusller.com"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.storefront.id
}
