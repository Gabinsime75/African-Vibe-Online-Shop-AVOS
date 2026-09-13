#############################################
# AWS Config Service Role
#############################################

module "config_service_role" {

  source = "../modules/service-roles/config-service-role"

  role_name = var.config_service_role_name

  tags = var.tags

}

#############################################
# AWS CloudTrail Service Role
#############################################

module "cloudtrail_service_role" {

  source = "../modules/service-roles/cloudtrail-service-role"

  role_name = var.cloudtrail_service_role_name

  tags = var.tags

}

#############################################
# Amazon GuardDuty Service Role
#############################################

module "guardduty_service_role" {

  source = "../modules/service-roles/guardduty-service-role"

  role_name = var.guardduty_service_role_name

  tags = var.tags

}

#############################################
# AWS Security Hub Service Role
#############################################

module "securityhub_service_role" {

  source = "../modules/service-roles/securityhub-service-role"

  role_name = var.securityhub_service_role_name

  tags = var.tags

}