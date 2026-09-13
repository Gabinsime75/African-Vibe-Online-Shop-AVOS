###############################################################
# CloudTrail Service Role
###############################################################

module "cloudtrail_service_role" {

  source = "../modules/service-roles/cloudtrail-service-role"

  role_name = var.cloudtrail_role_name

  tags = local.common_tags

}

###############################################################
# AWS Config Service Role
###############################################################

module "config_service_role" {

  source = "../modules/service-roles/config-service-role"

  role_name = var.config_role_name

  tags = local.common_tags

}

###############################################################
# GuardDuty Service Role
###############################################################

module "guardduty_service_role" {

  source = "../modules/service-roles/guardduty-service-role"

  role_name = var.guardduty_role_name

  tags = local.common_tags

}

###############################################################
# Security Hub Service Role
###############################################################

module "securityhub_service_role" {

  source = "../modules/service-roles/securityhub-service-role"

  role_name = var.securityhub_role_name

  tags = local.common_tags

}

###############################################################
# Config Aggregator Service Role
###############################################################

module "config_aggregator_role" {

  source = "../modules/service-roles/config-aggregator-role"

  role_name = local.config_aggregator_role_name

  tags = local.common_tags

}