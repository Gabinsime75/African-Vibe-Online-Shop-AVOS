###############################################################
# CloudTrail Log Group
###############################################################

module "cloudtrail_log_group" {

  source = "../modules/cloudwatch-log-group"

  name = "/aws/cloudtrail/${local.cloudtrail_name}"

  kms_key_id = module.governance_kms.key_arn

  retention_in_days = 365

  tags = local.common_tags

}