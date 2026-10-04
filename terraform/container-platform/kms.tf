# =============================================================================
# AVOS Container Platform — EKS KMS Encryption
#
# Creates the customer-managed KMS key used for Kubernetes Secrets encryption
# and EKS control-plane CloudWatch Logs encryption.
# =============================================================================

data "aws_iam_policy_document" "eks_kms" {
  statement {
    sid    = "EnableAccountIAMPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
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
        "logs.${var.aws_region}.${data.aws_partition.current.dns_suffix}"
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cluster_log_group_name}"
      ]
    }
  }
}

resource "aws_kms_key" "eks" {
  description = "Encrypts AVOS ${var.environment} EKS Kubernetes Secrets and control-plane logs"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false

  enable_key_rotation     = true
  rotation_period_in_days = var.kms_rotation_period_days

  deletion_window_in_days = var.kms_deletion_window_days

  policy = data.aws_iam_policy_document.eks_kms.json

  tags = {
    Name    = "${local.name_prefix}-eks"
    Purpose = "EKSEncryption"
  }
}

resource "aws_kms_alias" "eks" {
  name          = local.eks_kms_alias_name
  target_key_id = aws_kms_key.eks.key_id
}