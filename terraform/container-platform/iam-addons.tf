# =============================================================================
# AVOS Container Platform — Managed Add-on Pod Identity Roles
#
# Creates least-privilege IAM roles for the VPC CNI and EBS CSI managed
# add-ons. The roles are assumed through EKS Pod Identity.
# =============================================================================

data "aws_iam_policy_document" "eks_pod_identity_assume_role" {
  statement {
    sid    = "AllowEKSPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "vpc_cni" {
  name = "${local.cluster_name}-vpc-cni-role"

  description = "EKS Pod Identity role for the AVOS VPC CNI add-on"

  assume_role_policy = data.aws_iam_policy_document.eks_pod_identity_assume_role.json

  tags = {
    Name                     = "${local.cluster_name}-vpc-cni-role"
    Purpose                  = "EKSPodIdentity"
    KubernetesServiceAccount = "aws-node"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "ebs_csi" {
  name = "${local.cluster_name}-ebs-csi-role"

  description = "EKS Pod Identity role for the AVOS EBS CSI Driver add-on"

  assume_role_policy = data.aws_iam_policy_document.eks_pod_identity_assume_role.json

  tags = {
    Name                     = "${local.cluster_name}-ebs-csi-role"
    Purpose                  = "EKSPodIdentity"
    KubernetesServiceAccount = "ebs-csi-controller-sa"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}