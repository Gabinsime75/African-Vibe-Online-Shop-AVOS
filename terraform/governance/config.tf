# =============================================================================
# AVOS Governance — AWS Config
#
# Records supported AWS resource configurations and delivers encrypted
# configuration history and snapshots to the AVOS audit bucket.
# =============================================================================

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
  description      = "Allows AWS Config to record AVOS resource configurations"
}

resource "aws_config_configuration_recorder" "this" {
  name     = local.config_recorder_name
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  name = local.config_delivery_channel_name

  s3_bucket_name = aws_s3_bucket.audit_logs.id
  s3_kms_key_arn = aws_kms_key.audit_logs.arn

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_s3_bucket_policy.audit_logs,
    aws_s3_bucket_server_side_encryption_configuration.audit_logs
  ]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.this
  ]
}