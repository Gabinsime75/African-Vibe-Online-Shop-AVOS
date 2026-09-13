#############################################
# Outputs
#############################################

output "role_name" {

  description = "AWS CloudTrail IAM role name."

  value = module.cloudtrail_service_role.role_name

}

output "role_arn" {

  description = "AWS CloudTrail IAM role ARN."

  value = module.cloudtrail_service_role.role_arn

}

output "role_id" {
  value = module.cloudtrail_service_role.role_id
}