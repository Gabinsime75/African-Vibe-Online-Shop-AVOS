# =============================================================================
# AVOS Container Platform — Amazon EKS Control Plane
#
# Creates the AVOS EKS control plane with restricted API access, API-managed
# authentication, complete control-plane logging, and KMS Secrets encryption.
# =============================================================================

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.cluster_log_types

  bootstrap_self_managed_addons = false
  deletion_protection           = var.cluster_deletion_protection

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids = data.terraform_remote_state.networking.outputs.private_application_subnet_ids

    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }

    resources = [
      "secrets"
    ]
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_control_plane,
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy.eks_cluster_kms
  ]

  tags = {
    Name    = local.cluster_name
    Purpose = "ContainerPlatform"
  }

  timeouts {
    create = "45m"
    update = "60m"
    delete = "45m"
  }
}