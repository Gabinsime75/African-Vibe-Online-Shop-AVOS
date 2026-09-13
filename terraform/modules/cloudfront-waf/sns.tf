# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7.7 - WAF Alarm Notifications
#
# Purpose:
# Creates an SNS topic and email subscription used by CloudWatch WAF alarms.
# =============================================================================

resource "aws_sns_topic" "waf_alerts" {
  name = "${var.project_name}-${var.environment}-waf-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.waf_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}