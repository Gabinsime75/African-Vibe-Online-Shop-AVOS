# =============================================================================
# CloudHustler Commerce Platform
# Karpenter AWS Infrastructure and IAM
# =============================================================================
# Creates the AWS resources required by Karpenter:
#
# - Controller IAM role and scoped controller policy
# - EKS Pod Identity association
# - Karpenter worker-node IAM role
# - EKS access entry for dynamically provisioned nodes
# - SQS interruption queue
# - EventBridge interruption rules and targets
#
# The maintained terraform-aws-eks Karpenter submodule is wrapped here so the
# CloudHustler platform retains its own reusable module interface.
# =============================================================================

# -----------------------------------------------------------------------------
# Karpenter AWS Resources
# -----------------------------------------------------------------------------

module "karpenter_aws" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  region       = var.aws_region
  cluster_name = var.cluster_name

  # ---------------------------------------------------------------------------
  # EKS Pod Identity
  # ---------------------------------------------------------------------------

  namespace       = var.namespace
  service_account = var.service_account_name

  create_pod_identity_association = true

  # ---------------------------------------------------------------------------
  # Karpenter Controller IAM Role
  # ---------------------------------------------------------------------------

  iam_role_use_name_prefix = false
  enable_inline_policy     = true

  iam_role_name = coalesce(
    var.controller_iam_role_name,
    "${var.name_prefix}-karpenter-controller-role"
  )

  # ---------------------------------------------------------------------------
  # Karpenter Worker-Node IAM Role
  # ---------------------------------------------------------------------------

  create_node_iam_role          = true
  node_iam_role_use_name_prefix = false

  node_iam_role_name = coalesce(
    var.node_iam_role_name,
    "${var.name_prefix}-karpenter-node-role"
  )

  node_iam_role_additional_policies = var.node_iam_role_additional_policies

  # ---------------------------------------------------------------------------
  # EKS Node Authentication
  # ---------------------------------------------------------------------------

  create_access_entry = true
  access_entry_type   = "EC2_LINUX"

  # ---------------------------------------------------------------------------
  # EC2 Interruption Handling
  # ---------------------------------------------------------------------------

  enable_spot_termination = var.enable_interruption_handling
  queue_name              = local.karpenter_interruption_queue_name

  # ---------------------------------------------------------------------------
  # Resource Tags
  # ---------------------------------------------------------------------------

  tags = merge(
    var.tags,
    {
      Component = "Karpenter"
      Layer     = "Platform Services"
    }
  )
}