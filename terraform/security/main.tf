locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Security"
    },
    var.tags
  )
}


module "waf" {
  source = "../modules/waf"

  name        = "${local.name_prefix}-alb-waf"
  description = "WAF Web ACL for CloudHustler public Application Load Balancer."
  scope       = "REGIONAL"

  aws_region             = var.aws_region
  associate_resource_arn = var.alb_arn

  metric_name_prefix = "${local.name_prefix}-alb-waf"
  log_group_name     = "aws-waf-logs-${local.name_prefix}-alb"

  log_retention_in_days = var.waf_log_retention_in_days

  rate_limit         = var.waf_rate_limit
  allow_ip_addresses = var.waf_allow_ip_addresses
  block_ip_addresses = var.waf_block_ip_addresses

  enable_blocked_requests_alarm             = var.enable_waf_blocked_requests_alarm
  blocked_requests_alarm_threshold          = var.waf_blocked_requests_alarm_threshold
  blocked_requests_alarm_period             = var.waf_blocked_requests_alarm_period
  blocked_requests_alarm_evaluation_periods = var.waf_blocked_requests_alarm_evaluation_periods
  alarm_actions                             = var.waf_alarm_actions
  ok_actions                                = var.waf_ok_actions

  tags = local.common_tags
}