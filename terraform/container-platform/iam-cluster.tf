# =============================================================================
# AVOS Container Platform — EKS Cluster IAM Role
#
# Creates the IAM role assumed by the Amazon EKS control plane and grants the
# permissions needed to manage cluster AWS resources and the encryption grant.
# =============================================================================

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid    = "AllowEKSAssumeRole"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "${local.cluster_name}-cluster-role"

  description = "IAM role assumed by the AVOS ${var.environment} EKS control plane"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name    = "${local.cluster_name}-cluster-role"
    Purpose = "EKSControlPlane"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_cluster_kms" {
  statement {
    sid    = "AllowEKSEncryptionGrant"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.eks.arn
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_iam_role_policy" "eks_cluster_kms" {
  name = "${local.cluster_name}-kms"
  role = aws_iam_role.eks_cluster.id

  policy = data.aws_iam_policy_document.eks_cluster_kms.json
}