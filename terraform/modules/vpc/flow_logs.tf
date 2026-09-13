###############################################
# VPC Flow Logs
###############################################

resource "aws_flow_log" "this" {

  count = var.enable_flow_logs ? 1 : 0

  vpc_id = aws_vpc.this.id

  log_destination      = var.flow_logs_destination_arn
  log_destination_type = "cloud-watch-logs"

  iam_role_arn = var.flow_logs_iam_role_arn

  traffic_type = var.flow_logs_traffic_type

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flow-logs"
    }
  )

}