###############################################################
# CloudTrail
###############################################################

module "cloudtrail" {

  source = "../modules/cloudtrail"

  trail_name     = local.cloudtrail_name
  s3_bucket_name = module.cloudtrail_bucket.bucket_name

  # kms_key_id = module.governance_kms.key_arn

  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true

  # cloud_watch_logs_group_arn = "${module.cloudtrail_log_group.log_group_arn}:*"

  # cloud_watch_logs_role_arn = module.cloudtrail_service_role.role_arn

  tags = local.common_tags

  depends_on = [
    module.cloudtrail_bucket,
    module.cloudtrail_log_group,
    module.cloudtrail_service_role,
    module.governance_kms
  ]

}