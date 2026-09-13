# #############################################
# # CloudTrail Service Role
# #############################################

# module "cloudtrail_service_role" {

#   source = "../modules/service-roles/cloudtrail-service-role"

#   role_name = var.cloudtrail_role_name

#   tags = var.tags

# }

# #############################################
# # Config Service Role
# #############################################

# module "config_service_role" {

#   source = "../modules/service-roles/config-service-role"

#   role_name = var.config_role_name

#   tags = var.tags

# }

# #############################################
# # GuardDuty Service Role
# #############################################

# module "guardduty_service_role" {

#   source = "../modules/service-roles/guardduty-service-role"

#   role_name = var.guardduty_role_name

#   tags = var.tags

# }

# #############################################
# # Security Hub Service Role
# #############################################

# module "securityhub_service_role" {

#   source = "../modules/service-roles/securityhub-service-role"

#   role_name = var.securityhub_role_name

#   tags = var.tags

# }


# #############################################
# # CloudTrail Log Group
# #############################################
# module "cloudtrail_log_group" {
#   source = "../modules/cloudwatch-log-group"

#   name = "/aws/cloudtrail/cloudhustler"

#   kms_key_id = var.kms_key_arn

#   retention_in_days = 365

#   tags = var.tags
# }

# ###############################################################
# # CloudTrail
# ###############################################################

# module "cloudtrail" {

#   source = "../modules/cloudtrail"

#   trail_name = local.cloudtrail_name

#   s3_bucket_name = module.cloudtrail_bucket.bucket_name

#   kms_key_arn = module.governance_kms.key_arn

#   tags = local.common_tags

# }

# ###############################################################
# # AWS Config
# ###############################################################

# module "aws_config" {

#   source = "../modules/aws-config"

#   recorder_name = local.config_recorder_name

#   delivery_bucket_name = module.config_bucket.bucket_name

#   tags = local.common_tags

# }

# #############################################
# # GuardDuty
# #############################################

# module "guardduty" {

#   source = "../modules/guardduty"

#   tags = var.tags

# }

# #############################################
# # Security Hub
# #############################################

# module "securityhub" {

#   source = "../modules/securityhub"

#   tags = var.tags

# }

# #############################################
# # IAM Access Analyzer
# #############################################

# module "access_analyzer" {

#   source = "../modules/access-analyzer"

#   analyzer_name = var.access_analyzer_name

#   tags = var.tags

# }

# #############################################
# # Config Aggregator Service Role
# #############################################

# module "config_aggregator_role" {

#   source = "../modules/service-roles/config-aggregator-role"

#   role_name = "aws-config-aggregator-role"

#   tags = var.tags

# }

# #############################################
# # Config Aggregator
# #############################################

# module "config_aggregator" {

#   source = "../modules/config-aggregator"

#   aggregator_name           = "cloudhustler-config-aggregator"
#   organization_aggregation  = true

#   organization_role_arn = module.config_aggregator_role.role_arn

# }

# data "aws_iam_policy_document" "config_bucket_policy" {

#   statement {

#     sid    = "AWSConfigBucketPermissionsCheck"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["config.amazonaws.com"]
#     }

#     actions = [
#       "s3:GetBucketAcl"
#     ]

#     resources = [
#       "arn:aws:s3:::cloudhustler-config"
#     ]

#   }

#   statement {

#     sid    = "AWSConfigBucketDelivery"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["config.amazonaws.com"]
#     }

#     actions = [
#       "s3:PutObject"
#     ]

#     resources = [
#       "arn:aws:s3:::cloudhustler-config/AWSLogs/*"
#     ]

#     condition {

#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"

#       values = [
#         "bucket-owner-full-control"
#       ]

#     }

#   }

# }

# ###############################################################
# # AWS Config Bucket
# ###############################################################

# module "config_bucket" {

#   source = "../modules/s3"

#   bucket_name = local.config_bucket_name

#   force_destroy = false

#   enable_encryption = true

#   sse_algorithm = "aws:kms"

#   kms_key_arn = module.governance_kms.key_arn

#   versioning_status = "Enabled"

#   enable_public_access_block = true

#   object_ownership = "BucketOwnerEnforced"

#   tags = local.common_tags

# }
