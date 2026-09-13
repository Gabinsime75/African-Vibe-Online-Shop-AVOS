#############################################
# CloudTrail
#############################################

resource "aws_cloudtrail" "this" {

  name = var.trail_name

  s3_bucket_name = var.s3_bucket_name

  enable_logging = var.enable_logging

  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  enable_log_file_validation    = var.enable_log_file_validation
  is_organization_trail         = var.is_organization_trail

  # kms_key_id = var.kms_key_id

  # cloud_watch_logs_group_arn = var.cloud_watch_logs_group_arn
  # cloud_watch_logs_role_arn  = var.cloud_watch_logs_role_arn

  tags = var.tags

}