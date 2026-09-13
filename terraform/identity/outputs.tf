#############################################
# AWS Config Service Role
#############################################

output "config_service_role_name" {

  description = "AWS Config service role name."

  value = module.config_service_role.role_name

}

output "config_service_role_arn" {

  description = "AWS Config service role ARN."

  value = module.config_service_role.role_arn

}

#############################################
# AWS CloudTrail Service Role
#############################################

output "cloudtrail_service_role_name" {

  description = "CloudTrail service role name."

  value = module.cloudtrail_service_role.role_name

}

output "cloudtrail_service_role_arn" {

  description = "CloudTrail service role ARN."

  value = module.cloudtrail_service_role.role_arn

}

#############################################
# Amazon GuardDuty Service Role
#############################################

output "guardduty_service_role_name" {

  description = "GuardDuty service role name."

  value = module.guardduty_service_role.role_name

}

output "guardduty_service_role_arn" {

  description = "GuardDuty service role ARN."

  value = module.guardduty_service_role.role_arn

}

#############################################
# AWS Security Hub Service Role
#############################################

output "securityhub_service_role_name" {

  description = "Security Hub service role name."

  value = module.securityhub_service_role.role_name

}

output "securityhub_service_role_arn" {

  description = "Security Hub service role ARN."

  value = module.securityhub_service_role.role_arn

}