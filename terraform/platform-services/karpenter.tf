# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Platform Service
# =============================================================================
# Calls the reusable Karpenter module to deploy the Karpenter controller and
# create its supporting IAM, Pod Identity, node role, EKS access entry, SQS
# queue, and EventBridge interruption-handling resources.
# =============================================================================

module "karpenter" {
  source = "../modules/karpenter"

  # ---------------------------------------------------------------------------
  # General Configuration
  # ---------------------------------------------------------------------------

  aws_region  = var.aws_region
  name_prefix = local.name_prefix
  tags        = local.common_tags

  # ---------------------------------------------------------------------------
  # EKS Cluster Configuration
  # ---------------------------------------------------------------------------

  cluster_name     = data.aws_eks_cluster.this.name
  cluster_endpoint = data.aws_eks_cluster.this.endpoint

  # ---------------------------------------------------------------------------
  # Kubernetes Configuration
  # ---------------------------------------------------------------------------

  namespace            = var.karpenter_namespace
  service_account_name = var.karpenter_service_account_name

  # ---------------------------------------------------------------------------
  # Helm Configuration
  # ---------------------------------------------------------------------------

  chart_version       = var.karpenter_chart_version
  controller_replicas = var.karpenter_controller_replicas

  # ---------------------------------------------------------------------------
  # Controller Resource Configuration
  # ---------------------------------------------------------------------------

  controller_cpu_request    = var.karpenter_controller_cpu_request
  controller_memory_request = var.karpenter_controller_memory_request
  controller_cpu_limit      = var.karpenter_controller_cpu_limit
  controller_memory_limit   = var.karpenter_controller_memory_limit

  # ---------------------------------------------------------------------------
  # IAM Configuration
  # ---------------------------------------------------------------------------

  controller_iam_role_name = "${local.name_prefix}-karpenter-controller-role"
  node_iam_role_name       = "${local.name_prefix}-karpenter-node-role"

  # ---------------------------------------------------------------------------
  # Interruption Handling
  # ---------------------------------------------------------------------------

  enable_interruption_handling = var.karpenter_enable_interruption_handling
  interruption_queue_name      = "${local.name_prefix}-karpenter-interruption"
}