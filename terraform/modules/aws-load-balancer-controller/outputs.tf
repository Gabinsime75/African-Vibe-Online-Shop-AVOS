###############################################################
# IAM Outputs
###############################################################

output "iam_policy_arn" {
  description = "ARN of the IAM policy used by the AWS Load Balancer Controller."

  value = var.create_iam_policy ? (
    aws_iam_policy.this[0].arn
  ) : var.existing_iam_policy_arn
}

output "pod_identity_role_arn" {
  description = "ARN of the AWS Load Balancer Controller Pod Identity role."

  value = var.create_pod_identity_role ? (
    aws_iam_role.this[0].arn
  ) : var.existing_pod_identity_role_arn
}

output "pod_identity_association_id" {
  description = "ID of the EKS Pod Identity association."

  value = var.create_pod_identity_association ? (
    aws_eks_pod_identity_association.this[0].association_id
  ) : null
}

###############################################################
# Helm Outputs
###############################################################

output "release_name" {
  description = "Name of the AWS Load Balancer Controller Helm release."
  value       = helm_release.this.name
}

output "release_namespace" {
  description = "Namespace containing the controller."
  value       = helm_release.this.namespace
}

output "release_status" {
  description = "Status of the AWS Load Balancer Controller Helm release."
  value       = helm_release.this.status
}

output "service_account_name" {
  description = "Kubernetes service account used by the controller."
  value       = var.service_account_name
}

output "managed_target_group_arns" {
  description = "Target-group ARNs the controller is permitted to manage."
  value       = var.target_group_arns
}