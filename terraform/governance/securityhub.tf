###############################################################
# AWS Security Hub
###############################################################

module "securityhub" {

  source = "../modules/securityhub"

  enable_default_standards = true

  tags = local.common_tags

}