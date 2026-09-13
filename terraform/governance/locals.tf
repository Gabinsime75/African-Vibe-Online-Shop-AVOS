# ###############################################################
# # Local Values
# ###############################################################

# locals {

#   #############################################################
#   # Naming
#   #############################################################

#   name_prefix = "${var.project_name}-${var.environment}"

#   #############################################################
#   # Resource Names
#   #############################################################

#   governance_kms_alias = "alias/${local.name_prefix}-governance"

#   cloudtrail_name = "${local.name_prefix}-cloudtrail"

#   cloudtrail_bucket = "${local.name_prefix}-cloudtrail"

#   config_bucket = "${local.name_prefix}-config"

#   config_recorder = "${local.name_prefix}-config-recorder"

#   access_analyzer = "${local.name_prefix}-access-analyzer"

#   #############################################################
#   # Tags
#   #############################################################

#   common_tags = merge(

#     {

#       Project = var.project_name

#       Environment = var.environment

#       Layer = "governance"

#       Terraform = "true"

#       ManagedBy = "Terraform"

#     },

#     var.tags

#   )

# }

###############################################################
# Governance Resource Names
###############################################################

locals {

  name_prefix = "${var.project_name}-${var.environment}"

  governance_kms_key_alias = "alias/${local.name_prefix}-governance"

  cloudtrail_name = "${local.name_prefix}-cloudtrail"

  cloudtrail_bucket_name = "${local.name_prefix}-cloudtrail"

  config_bucket_name = "${local.name_prefix}-config"

  config_recorder_name = "${local.name_prefix}-config-recorder"

  config_delivery_channel_name = "${local.name_prefix}-delivery-channel"

  config_aggregator_name = "${local.name_prefix}-config-aggregator"

  config_aggregator_role_name = "${local.name_prefix}-config-aggregator-role"

  access_analyzer_name = "${local.name_prefix}-access-analyzer"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Layer       = "governance"
      Terraform   = "true"
      ManagedBy   = "Terraform"
    },
    var.tags
  )

}

# locals {

#   name_prefix = "${var.project_name}-${var.environment}"

#   common_tags = merge(
#     {
#       Project     = var.project_name
#       Environment = var.environment
#       Layer       = "governance"
#       Terraform   = "true"
#       ManagedBy   = "Terraform"
#     },
#     var.tags
#   )

#   cloudtrail_name            = "${local.name_prefix}-cloudtrail"
#   cloudtrail_bucket_name     = "${local.name_prefix}-cloudtrail"
#   config_bucket_name         = "${local.name_prefix}-config"
#   config_recorder_name       = "${local.name_prefix}-config-recorder"
#   config_aggregator_name     = "${local.name_prefix}-config-aggregator"
#   config_aggregator_role_name = "${local.name_prefix}-config-aggregator-role"
#   access_analyzer_name       = "${local.name_prefix}-access-analyzer"
# }