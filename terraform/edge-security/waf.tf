# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7 - CloudFront WAF
#
# Purpose:
# Deploys the CloudFront-scoped AWS WAF Web ACL.
#
# CloudFront WAF resources use us-east-1 even though the main platform
# infrastructure runs in us-east-2.
# =============================================================================

module "cloudfront_waf" {
  source = "../modules/cloudfront-waf"

  providers = {
    aws = aws.us_east_1
  }

  project_name = var.project_name
  environment  = var.environment

  rate_limit         = var.waf_rate_limit
  log_retention_days = var.waf_log_retention_days

  blocked_requests_threshold = var.waf_blocked_requests_threshold
  rate_limit_alarm_threshold = var.waf_rate_limit_alarm_threshold

  alert_email = var.waf_alert_email

  tags = var.tags
}