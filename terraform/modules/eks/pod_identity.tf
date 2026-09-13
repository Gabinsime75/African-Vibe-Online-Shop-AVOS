###############################################################
# EBS CSI Driver Pod Identity IAM Role
###############################################################

resource "aws_iam_role" "ebs_csi_pod_identity" {
  count = var.enable_ebs_csi_driver && var.create_ebs_csi_pod_identity ? 1 : 0

  name = "${local.cluster_name}-ebs-csi-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowEksPodIdentity"
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.cluster_name}-ebs-csi-pod-identity-role"
      Component = "aws-ebs-csi-driver"
    }
  )
}

###############################################################
# EBS CSI Driver IAM Policy Attachment
###############################################################

resource "aws_iam_role_policy_attachment" "ebs_csi_pod_identity" {
  count = var.enable_ebs_csi_driver && var.create_ebs_csi_pod_identity ? 1 : 0

  role = aws_iam_role.ebs_csi_pod_identity[0].name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

###############################################################
# EBS CSI Driver Pod Identity Association
###############################################################

resource "aws_eks_pod_identity_association" "ebs_csi" {
  count = var.enable_ebs_csi_driver && var.create_ebs_csi_pod_identity ? 1 : 0

  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_pod_identity[0].arn

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.cluster_name}-ebs-csi-pod-identity"
      Component = "aws-ebs-csi-driver"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_pod_identity,
    aws_eks_addon.pod_identity_agent
  ]
}