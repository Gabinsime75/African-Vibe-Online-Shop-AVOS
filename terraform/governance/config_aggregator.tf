###############################################################
# AWS Config Aggregator
###############################################################

module "config_aggregator" {

  source = "../modules/config-aggregator"

  aggregator_name = local.config_aggregator_name

  organization_aggregation = true

  organization_role_arn = module.config_aggregator_role.role_arn

  tags = local.common_tags

}