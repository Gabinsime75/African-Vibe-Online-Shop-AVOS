# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront
# Phase 7.1 - CloudFront Foundation
#
# Purpose:
# Creates the Amazon CloudFront distribution that provides the edge delivery
# layer for the CloudHustler Commerce Platform.
#
# In Phase 7.1, the existing public Application Load Balancer is configured as
# the CloudFront custom origin. The CloudFront-generated domain name and default
# certificate are used for initial validation.
#
# Custom DNS, ACM integration, caching policies, compression, security headers,
# and WAF integration are implemented in later Phase 7 workstreams.
#
# Traffic Flow:
#
# Internet
#    |
#    v
# CloudFront
#    |
#    | HTTPS
#    v
# Application Load Balancer
# =============================================================================

# -----------------------------------------------------------------------------
# CloudFront Distribution
# -----------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = var.aliases

  comment = "${var.project_name}-${var.environment}-cloudfront"

  web_acl_id = var.web_acl_id

  price_class = var.price_class

  # ---------------------------------------------------------------------------
  # Application Load Balancer Origin
  # ---------------------------------------------------------------------------

  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"

      origin_ssl_protocols = [
        "TLSv1.2"
      ]

      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  # ---------------------------------------------------------------------------
  # Default Cache Behavior
  #
  # Caching is intentionally disabled during Phase 7.1.
  # Dedicated CloudFront cache policies are introduced in Phase 7.3.
  # ---------------------------------------------------------------------------

  default_cache_behavior {
    target_origin_id = var.origin_id

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    cache_policy_id = var.default_cache_policy_id

    origin_request_policy_id = var.default_origin_request_policy_id

    response_headers_policy_id = var.default_response_headers_policy_id

    compress = true
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    target_origin_id = var.origin_id

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    cache_policy_id = var.static_cache_policy_id

    origin_request_policy_id = var.static_origin_request_policy_id

    response_headers_policy_id = var.static_response_headers_policy_id

    compress = true
  }

  # ---------------------------------------------------------------------------
  # Geographic Restrictions
  # ---------------------------------------------------------------------------

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ---------------------------------------------------------------------------
  # Viewer Certificate
  #
  # Phase 7.1 uses the CloudFront-generated hostname and default certificate.
  # Custom ACM integration is implemented in Phase 7.2.
  # ---------------------------------------------------------------------------

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # ---------------------------------------------------------------------------
  # Resource Tags
  # ---------------------------------------------------------------------------

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-cloudfront"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Phase       = "Edge-Security"
    }
  )
}