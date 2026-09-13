# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7.6 - WAF Logging
#
# Purpose:
# Sends AWS WAF request logs to CloudWatch Logs for security analysis,
# troubleshooting, and rule tuning.
#
# CloudFront-scoped WAF resources and their logging configuration use
# us-east-1.
# =============================================================================

resource "aws_cloudwatch_log_group" "waf" {
  name = "aws-waf-logs-${var.project_name}-${var.environment}-cloudfront"

  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn = aws_wafv2_web_acl.this.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.waf.arn
  ]

  depends_on = [
    aws_cloudwatch_log_group.waf
  ]
}