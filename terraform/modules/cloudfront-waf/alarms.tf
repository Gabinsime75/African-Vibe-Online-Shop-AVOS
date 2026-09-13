# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7.7 - WAF CloudWatch Alarms
#
# Purpose:
# Creates CloudWatch alarms for important AWS WAF security events.
#
# Initial alarms:
# - Overall blocked request spike
# - Rate-limit rule activity
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "blocked_requests" {
  alarm_name          = "${var.project_name}-${var.environment}-waf-blocked-requests"
  alarm_description   = "Alerts when AWS WAF blocks an elevated number of requests."
  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = 1
  period             = 300
  threshold          = var.blocked_requests_threshold

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = aws_wafv2_web_acl.this.name
    Region = "CloudFront"
  }

  alarm_actions = [
    aws_sns_topic.waf_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.waf_alerts.arn
  ]

  treat_missing_data = "notBreaching"

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rate_limit" {
  alarm_name          = "${var.project_name}-${var.environment}-waf-rate-limit"
  alarm_description   = "Alerts when the WAF rate-limit rule begins blocking requests."
  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = 1
  period             = 300
  threshold          = var.rate_limit_alarm_threshold

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = aws_wafv2_web_acl.this.name
    Rule   = "RateLimitPerIP"
    Region = "CloudFront"
  }

  treat_missing_data = "notBreaching"


  alarm_actions = [
    aws_sns_topic.waf_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.waf_alerts.arn
  ]
  tags = var.tags
}