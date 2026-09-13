# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.4 - Origin Request Policies
#
# Purpose:
# References AWS-managed CloudFront origin request policies.
#
# Strategy:
# - Default/dynamic traffic forwards complete viewer request context.
# - Static content forwards only the Origin header required for CORS.
# =============================================================================

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "cors_custom_origin" {
  name = "Managed-CORS-CustomOrigin"
}