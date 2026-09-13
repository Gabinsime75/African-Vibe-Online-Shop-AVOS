locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "ContainerPlatform"
    },
    var.tags
  )
}

module "eks" {
  source = "../modules/eks"

  cluster_name       = "${local.name_prefix}-eks"
  kubernetes_version = var.kubernetes_version

  subnet_ids                 = var.private_app_subnet_ids
  cluster_security_group_ids = var.cluster_security_group_ids

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  enabled_cluster_log_types = var.enabled_cluster_log_types

  enable_secrets_encryption = var.enable_secrets_encryption
  create_kms_key            = var.create_kms_key
  kms_key_arn               = var.kms_key_arn

  create_cloudwatch_log_group      = var.create_cloudwatch_log_group
  cloudwatch_log_retention_in_days = var.cloudwatch_log_retention_in_days
  cloudwatch_log_kms_key_id        = var.cloudwatch_log_kms_key_id

  node_groups = var.node_groups

  enable_vpc_cni            = var.enable_vpc_cni
  enable_coredns            = var.enable_coredns
  enable_kube_proxy         = var.enable_kube_proxy
  enable_ebs_csi_driver     = var.enable_ebs_csi_driver
  enable_pod_identity_agent = var.enable_pod_identity_agent

  vpc_cni_version            = var.vpc_cni_version
  coredns_version            = var.coredns_version
  kube_proxy_version         = var.kube_proxy_version
  ebs_csi_driver_version     = var.ebs_csi_driver_version
  pod_identity_agent_version = var.pod_identity_agent_version
  # ebs_csi_role_arn           = var.ebs_csi_role_arn
  # enable_ebs_csi_driver         = var.enable_ebs_csi_driver
  create_ebs_csi_pod_identity = var.create_ebs_csi_pod_identity
  # enable_pod_identity_agent     = var.enable_pod_identity_agent

  enable_oidc_provider = var.enable_oidc_provider
  access_entries       = var.access_entries

  tags = local.common_tags
}