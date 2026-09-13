# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Module Outputs
# =============================================================================
# Exposes Karpenter IAM, interruption queue, node role, and Helm deployment
# information to the platform-services Terraform root.
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Release
# -----------------------------------------------------------------------------

output "helm_release_name" {
  description = "Name of the Karpenter Helm release."
  value       = helm_release.karpenter.name
}

output "namespace" {
  description = "Namespace where Karpenter is installed."
  value       = helm_release.karpenter.namespace
}

output "chart_version" {
  description = "Installed Karpenter Helm chart version."
  value       = helm_release.karpenter.version
}

# -----------------------------------------------------------------------------
# Controller IAM
# -----------------------------------------------------------------------------

output "controller_iam_role_arn" {
  description = "ARN of the Karpenter controller IAM role."
  value       = module.karpenter_aws.iam_role_arn
}

output "controller_iam_role_name" {
  description = "Name of the Karpenter controller IAM role."
  value       = module.karpenter_aws.iam_role_name
}

# -----------------------------------------------------------------------------
# Worker-Node IAM
# -----------------------------------------------------------------------------

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by Karpenter-managed EC2 nodes."
  value       = module.karpenter_aws.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "Name of the IAM role used by Karpenter-managed EC2 nodes."
  value       = module.karpenter_aws.node_iam_role_name
}

# -----------------------------------------------------------------------------
# Interruption Handling
# -----------------------------------------------------------------------------

output "interruption_queue_name" {
  description = "Name of the SQS interruption queue used by Karpenter."
  value       = module.karpenter_aws.queue_name
}

output "interruption_queue_arn" {
  description = "ARN of the SQS interruption queue used by Karpenter."
  value       = module.karpenter_aws.queue_arn
}