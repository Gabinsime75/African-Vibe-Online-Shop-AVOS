# =============================================================================
# AVOS Container Platform — Pre-Compute EKS Managed Add-ons
#
# Installs the networking and Pod Identity components required before the
# stable managed node group joins the Kubernetes cluster.
# =============================================================================

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.addon_versions["eks-pod-identity-agent"]

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name    = "${local.cluster_name}-pod-identity-agent"
    Purpose = "EKSPodIdentity"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "vpc-cni"
  addon_version = var.addon_versions["vpc-cni"]

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = aws_iam_role.vpc_cni.arn
    service_account = "aws-node"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.vpc_cni
  ]

  tags = {
    Name    = "${local.cluster_name}-vpc-cni"
    Purpose = "PodNetworking"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "kube-proxy"
  addon_version = var.addon_versions["kube-proxy"]

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name    = "${local.cluster_name}-kube-proxy"
    Purpose = "ServiceNetworking"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}