# =============================================================================
# AVOS Network Foundation — VPC Flow Logs IAM Role
#
# Allows the VPC Flow Logs service to assume a dedicated IAM role and publish
# log streams and events to the AVOS CloudWatch Logs destination.
# =============================================================================

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    sid    = "AllowVPCFlowLogsAssumeRole"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        var.aws_account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:vpc-flow-log/*"
      ]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs"

  description          = "Allows AVOS VPC Flow Logs to publish to CloudWatch Logs"
  assume_role_policy   = data.aws_iam_policy_document.flow_logs_assume_role.json
  max_session_duration = 3600

  tags = {
    Name    = "${local.name_prefix}-vpc-flow-logs"
    Purpose = "VPCFlowLogsDelivery"
  }
}

data "aws_iam_policy_document" "flow_logs_delivery" {
  statement {
    sid    = "WriteFlowLogEvents"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }

  statement {
    sid    = "DescribeCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs-delivery"
  role = aws_iam_role.flow_logs.id

  policy = data.aws_iam_policy_document.flow_logs_delivery.json
}