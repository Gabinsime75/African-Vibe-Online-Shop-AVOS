resource "aws_cloudwatch_metric_alarm" "blocked_requests" {
  count = var.enable_blocked_requests_alarm ? 1 : 0

  alarm_name          = "${var.name}-blocked-requests-high"
  alarm_description   = "High number of blocked requests detected by AWS WAF."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.blocked_requests_alarm_evaluation_periods
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = var.blocked_requests_alarm_period
  statistic           = "Sum"
  threshold           = var.blocked_requests_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.this.name
    Region = var.aws_region
    Rule   = "ALL"
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = var.tags
}