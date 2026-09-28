# =============================================================================
# AVOS Secrets Manager KMS Key
#
# Provides a dedicated customer-managed symmetric KMS key for encrypting AVOS
# application secrets stored in AWS Secrets Manager.
# =============================================================================

data "aws_iam_policy_document" "secrets_kms" {
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
}

resource "aws_kms_key" "secrets" {
  description = "Encrypts AVOS ${var.environment} application secrets"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false

  enable_key_rotation     = true
  rotation_period_in_days = 365
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.secrets_kms.json

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-secrets"
      Purpose = "SecretsManagerEncryption"
    }
  )
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}