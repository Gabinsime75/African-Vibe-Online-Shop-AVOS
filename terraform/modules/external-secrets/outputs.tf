################################################################################
# External Secrets Operator Outputs
#
# These outputs expose the primary resources created by the External Secrets
# module for use by other Terraform configurations and for operational
# visibility.
################################################################################

################################################################################
# Namespace
################################################################################

output "namespace" {
  description = "Namespace where External Secrets Operator is deployed."

  value = var.namespace
}

################################################################################
# Service Account
################################################################################

output "service_account_name" {
  description = "Kubernetes ServiceAccount used by External Secrets Operator."

  value = var.service_account_name
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "IAM role used by External Secrets Operator."

  value = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by External Secrets Operator."

  value = aws_iam_role.this.arn
}

################################################################################
# IAM Policy
################################################################################

output "iam_policy_name" {
  description = "IAM policy attached to the External Secrets Operator role."

  value = aws_iam_policy.this.name
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy attached to the External Secrets Operator role."

  value = aws_iam_policy.this.arn
}

################################################################################
# EKS Pod Identity
################################################################################

output "pod_identity_association_id" {
  description = "ID of the Amazon EKS Pod Identity association."

  value = aws_eks_pod_identity_association.this.association_id
}

################################################################################
# Helm Release
################################################################################

output "helm_release_name" {
  description = "Name of the Helm release."

  value = helm_release.this.name
}

output "helm_chart" {
  description = "Helm chart deployed."

  value = helm_release.this.chart
}

output "helm_chart_version" {
  description = "Version of the deployed Helm chart."

  value = helm_release.this.version
}

output "helm_release_status" {
  description = "Status of the Helm release."

  value = helm_release.this.status
}

################################################################################
# ClusterSecretStore
################################################################################

output "cluster_secret_store_name" {
  description = "Name of the ClusterSecretStore."

  value = var.create_cluster_secret_store ? local.secret_store.name : null
}

################################################################################
# Feature Flags
################################################################################

output "secrets_manager_enabled" {
  description = "Whether AWS Secrets Manager integration is enabled."

  value = var.enable_secrets_manager
}

output "parameter_store_enabled" {
  description = "Whether AWS Systems Manager Parameter Store integration is enabled."

  value = var.enable_parameter_store
}

################################################################################
# Observability
################################################################################

output "service_monitor_enabled" {
  description = "Whether Prometheus ServiceMonitor resources are enabled."

  value = var.enable_service_monitor
}