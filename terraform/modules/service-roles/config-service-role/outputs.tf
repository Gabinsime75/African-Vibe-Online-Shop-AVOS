output "role_name" {
  description = "AWS Config IAM role name."
  value       = module.config_service_role.role_name
}

output "role_arn" {
  description = "AWS Config IAM role ARN."
  value       = module.config_service_role.role_arn
}

output "role_id" {
  value = module.config_service_role.role_id
}