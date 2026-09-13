output "web_acl_id" {
  description = "ID of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "Name of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.name
}

output "web_acl_capacity" {
  description = "WCU capacity used by the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.capacity
}

output "log_group_name" {
  description = "Name of the WAF CloudWatch Log Group."
  value       = var.enable_logging ? aws_cloudwatch_log_group.this[0].name : null
}

output "log_group_arn" {
  description = "ARN of the WAF CloudWatch Log Group."
  value       = var.enable_logging ? aws_cloudwatch_log_group.this[0].arn : null
}

output "allow_ip_set_arn" {
  description = "ARN of the allow IP set."
  value       = length(var.allow_ip_addresses) > 0 ? aws_wafv2_ip_set.allow[0].arn : null
}

output "block_ip_set_arn" {
  description = "ARN of the block IP set."
  value       = length(var.block_ip_addresses) > 0 ? aws_wafv2_ip_set.block[0].arn : null
}

output "blocked_requests_alarm_name" {
  description = "Name of the blocked requests CloudWatch alarm."
  value       = var.enable_blocked_requests_alarm ? aws_cloudwatch_metric_alarm.blocked_requests[0].alarm_name : null
}