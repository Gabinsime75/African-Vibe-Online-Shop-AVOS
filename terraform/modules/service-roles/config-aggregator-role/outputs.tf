output "role_name" {
  description = "IAM role name."
  value       = module.config_aggregator_role.role_name
}

output "role_arn" {
  description = "IAM role ARN."
  value       = module.config_aggregator_role.role_arn
}

output "role_id" {
  description = "IAM role ID."
  value       = module.config_aggregator_role.role_id
}