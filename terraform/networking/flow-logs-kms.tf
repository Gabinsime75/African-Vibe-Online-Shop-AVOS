# =============================================================================
# AVOS Network Foundation — VPC Flow Logs KMS Key
#
# Creates a customer-managed KMS key used exclusively to encrypt the AVOS
# CloudWatch Logs log group that receives VPC Flow Logs.
# =============================================================================

data "aws_iam_policy_document" "flow_logs_kms" {
  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogsEncryption"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.aws_region}.amazonaws.com"
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${local.flow_log_group_name}"
      ]
    }
  }
}

resource "aws_kms_key" "flow_logs" {
  description = "Encrypts AVOS ${var.environment} VPC Flow Logs"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false

  enable_key_rotation     = true
  rotation_period_in_days = 365
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.flow_logs_kms.json

  tags = {
    Name    = "${local.name_prefix}-vpc-flow-logs"
    Purpose = "VPCFlowLogsEncryption"
  }
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${local.name_prefix}-vpc-flow-logs"
  target_key_id = aws_kms_key.flow_logs.key_id
}