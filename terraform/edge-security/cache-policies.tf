# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.3 - CloudFront Cache Policies
#
# Purpose:
# References AWS-managed CloudFront cache policies used by the CloudHustler
# distribution.
#
# Strategy:
# - Dynamic/default traffic: caching disabled
# - Static content: caching optimized
# =============================================================================

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}