###############################################################
# Amazon GuardDuty
###############################################################

module "guardduty" {

  source = "../modules/guardduty"
  tags   = local.common_tags

}