output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL."
  value       = module.waf.web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL."
  value       = module.waf.web_acl_arn
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL."
  value       = module.waf.web_acl_name
}

output "waf_web_acl_capacity" {
  description = "WCU capacity used by the WAF Web ACL."
  value       = module.waf.web_acl_capacity
}

output "waf_log_group_name" {
  description = "Name of the WAF CloudWatch Log Group."
  value       = module.waf.log_group_name
}

output "waf_log_group_arn" {
  description = "ARN of the WAF CloudWatch Log Group."
  value       = module.waf.log_group_arn
}