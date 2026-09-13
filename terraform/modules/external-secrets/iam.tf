################################################################################
# External Secrets Operator IAM Configuration
#
# This file provisions the AWS IAM resources required by External Secrets
# Operator to securely retrieve secrets from AWS Secrets Manager and optionally
# AWS Systems Manager Parameter Store using Amazon EKS Pod Identity.
#
# Resources Created
# • IAM Policy
# • IAM Role
# • IAM Role Policy Attachment
# • EKS Pod Identity Association
#
# Authentication Flow
#
# AWS Secrets Manager / Parameter Store
#                 │
#                 ▼
#             IAM Policy
#                 │
#                 ▼
#              IAM Role
#                 │
#                 ▼
#         EKS Pod Identity
#                 │
#                 ▼
#    External Secrets Operator Pod
################################################################################

################################################################################
# IAM Trust Policy
################################################################################

data "aws_iam_policy_document" "pod_identity_assume_role" {

  statement {

    sid = "AllowEksAuthToAssumeRoleForPodIdentity"

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {

      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    condition {

      test = "StringEquals"

      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        var.namespace
      ]
    }

    condition {

      test = "StringEquals"

      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        var.service_account_name
      ]
    }
  }
}

################################################################################
# IAM Permissions
################################################################################

data "aws_iam_policy_document" "external_secrets" {

  ##############################################################################
  # AWS Secrets Manager
  ##############################################################################

  dynamic "statement" {

    for_each = (
      var.enable_secrets_manager &&
      length(var.secrets_manager_secret_arns) > 0
    ) ? [1] : []

    content {

      sid = "SecretsManagerRead"

      effect = "Allow"

      actions = [

        "secretsmanager:GetSecretValue",

        "secretsmanager:DescribeSecret",

        "secretsmanager:ListSecretVersionIds"
      ]

      resources = var.secrets_manager_secret_arns
    }
  }

  ##############################################################################
  # AWS Systems Manager Parameter Store
  ##############################################################################

  dynamic "statement" {

    for_each = (
      var.enable_parameter_store &&
      length(var.parameter_store_parameter_arns) > 0
    ) ? [1] : []

    content {

      sid = "ParameterStoreRead"

      effect = "Allow"

      actions = [

        "ssm:GetParameter",

        "ssm:GetParameters",

        "ssm:GetParametersByPath"
      ]

      resources = var.parameter_store_parameter_arns
    }
  }

  ##############################################################################
  # AWS KMS
  ##############################################################################

  dynamic "statement" {

    for_each = length(var.kms_key_arns) > 0 ? [1] : []

    content {

      sid = "DecryptSecrets"

      effect = "Allow"

      actions = [

        "kms:Decrypt"
      ]

      resources = var.kms_key_arns
    }
  }
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "this" {

  name = local.iam_role_name

  description = "IAM role used by External Secrets Operator through EKS Pod Identity."

  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role.json

  tags = local.common_tags
}

################################################################################
# IAM Policy
################################################################################

resource "aws_iam_policy" "this" {

  name = local.iam_policy_name

  description = "Allows External Secrets Operator to retrieve approved AWS secrets."

  policy = data.aws_iam_policy_document.external_secrets.json

  tags = local.common_tags
}

################################################################################
# IAM Policy Attachment
################################################################################

resource "aws_iam_role_policy_attachment" "this" {

  role = aws_iam_role.this.name

  policy_arn = aws_iam_policy.this.arn
}

################################################################################
# Amazon EKS Pod Identity Association
################################################################################

resource "aws_eks_pod_identity_association" "this" {

  cluster_name = var.cluster_name

  namespace = var.namespace

  service_account = var.service_account_name

  role_arn = aws_iam_role.this.arn

  tags = merge(

    local.common_tags,

    {
      Name = local.pod_identity_name
    }
  )
}