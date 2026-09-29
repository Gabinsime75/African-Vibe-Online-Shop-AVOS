# =============================================================================
# AVOS Network Foundation — Flow Logs CloudWatch Destination
#
# Creates the encrypted CloudWatch Logs group that stores AVOS VPC Flow Logs
# and automatically expires records according to the configured retention.
# =============================================================================

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = local.flow_log_group_name

  log_group_class   = "STANDARD"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name    = "${local.name_prefix}-vpc-flow-logs"
    Purpose = "VPCFlowLogs"
  }
}