# =============================================================================
# AVOS Network Foundation — VPC Flow Log
#
# Captures accepted and rejected network-flow metadata for the entire AVOS VPC
# and delivers it to the encrypted CloudWatch Logs destination.
# =============================================================================

resource "aws_flow_log" "this" {
  vpc_id = aws_vpc.this.id

  traffic_type             = "ALL"
  max_aggregation_interval = 60

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs.arn

  log_format = join(" ", [
    "$${version}",
    "$${account-id}",
    "$${interface-id}",
    "$${srcaddr}",
    "$${dstaddr}",
    "$${srcport}",
    "$${dstport}",
    "$${protocol}",
    "$${packets}",
    "$${bytes}",
    "$${start}",
    "$${end}",
    "$${action}",
    "$${log-status}",
    "$${vpc-id}",
    "$${subnet-id}",
    "$${instance-id}",
    "$${tcp-flags}",
    "$${type}",
    "$${pkt-srcaddr}",
    "$${pkt-dstaddr}",
    "$${region}",
    "$${az-id}",
    "$${pkt-src-aws-service}",
    "$${pkt-dst-aws-service}",
    "$${flow-direction}",
    "$${traffic-path}"
  ])

  tags = {
    Name    = "${local.name_prefix}-vpc-flow-log"
    Purpose = "NetworkObservability"
  }

  depends_on = [
    aws_iam_role_policy.flow_logs
  ]
}