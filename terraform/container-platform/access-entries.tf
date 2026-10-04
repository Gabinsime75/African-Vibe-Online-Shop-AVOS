# =============================================================================
# AVOS Container Platform — EKS Access Entries
#
# Grants the approved AVOS IAM Identity Center administrator role explicit
# cluster access through the EKS Access Entry API.
# =============================================================================

resource "aws_eks_access_entry" "administrator" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.administrator_role_arn
  type          = "STANDARD"

  tags = {
    Name       = "${local.cluster_name}-administrator"
    AccessType = "ClusterAdministrator"
  }
}

resource "aws_eks_access_policy_association" "administrator" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.administrator.principal_arn

  policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}