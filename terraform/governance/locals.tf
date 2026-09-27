# =============================================================================
# AVOS Governance — Derived Names and Common Tags
#
# Defines reusable values calculated from variables and AWS account data.
# Local values reduce duplication and standardize naming across resources.
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  audit_log_bucket_name = join(
    "-",
    [
      local.name_prefix,
      "audit-logs",
      data.aws_caller_identity.current.account_id,
      var.aws_region
    ]
  )

  audit_kms_alias_name         = "alias/${local.name_prefix}-audit-logs"
  cloudtrail_name              = "${local.name_prefix}-management-events"
  config_recorder_name         = "${local.name_prefix}-configuration-recorder"
  config_delivery_channel_name = "${local.name_prefix}-configuration-delivery"

  mandatory_tags = {
    Project     = upper(var.project_name)
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Repository  = var.repository_name
    Phase       = "3"
    Component   = "Governance"
  }

  common_tags = merge(
    var.additional_tags,
    local.mandatory_tags
  )

  cloudtrail_arn = format(
    "arn:%s:cloudtrail:%s:%s:trail/%s",
    data.aws_partition.current.partition,
    var.aws_region,
    data.aws_caller_identity.current.account_id,
    local.cloudtrail_name
  )
}