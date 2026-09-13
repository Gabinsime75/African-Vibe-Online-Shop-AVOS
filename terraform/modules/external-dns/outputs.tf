################################################################################
# ExternalDNS Module Outputs
#
# This file exposes the key AWS and Kubernetes resources created by the
# ExternalDNS module.
#
# These outputs support:
#
# 1. Root-module visibility.
# 2. Downstream module integration.
# 3. Operational troubleshooting.
# 4. IAM validation.
# 5. EKS Pod Identity verification.
# 6. Helm release verification.
#
# Exposed resources:
#
# - ExternalDNS IAM role
# - ExternalDNS IAM policy
# - EKS Pod Identity association
# - Kubernetes namespace
# - Kubernetes service account
# - Helm release metadata
################################################################################


################################################################################
# IAM Role Outputs
################################################################################

output "iam_role_name" {
  description = "Name of the IAM role used by ExternalDNS through EKS Pod Identity."
  value       = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by ExternalDNS through EKS Pod Identity."
  value       = aws_iam_role.this.arn
}


################################################################################
# IAM Policy Outputs
################################################################################

output "iam_policy_name" {
  description = "Name of the customer-managed IAM policy that grants ExternalDNS Route 53 permissions."
  value       = aws_iam_policy.this.name
}

output "iam_policy_arn" {
  description = "ARN of the customer-managed IAM policy that grants ExternalDNS Route 53 permissions."
  value       = aws_iam_policy.this.arn
}


################################################################################
# EKS Pod Identity Outputs
################################################################################

output "pod_identity_association_id" {
  description = "Identifier of the EKS Pod Identity association created for ExternalDNS."
  value       = aws_eks_pod_identity_association.this.association_id
}

################ if Terraform reports that association_arn is not exported by aws_eks_pod_identity_association, remove only this output: ##################
output "pod_identity_association_arn" {
  description = "ARN of the EKS Pod Identity association created for ExternalDNS."
  value       = aws_eks_pod_identity_association.this.association_arn
}


################################################################################
# Kubernetes Namespace and Service Account Outputs
################################################################################

output "namespace" {
  description = "Kubernetes namespace in which ExternalDNS is deployed."
  value       = kubernetes_namespace.this.metadata[0].name
}

output "service_account_name" {
  description = "Kubernetes service account used by ExternalDNS."
  value       = var.service_account_name
}


################################################################################
# Helm Release Outputs
################################################################################

output "helm_release_name" {
  description = "Name of the ExternalDNS Helm release."
  value       = helm_release.this.name
}

output "helm_release_namespace" {
  description = "Namespace of the ExternalDNS Helm release."
  value       = helm_release.this.namespace
}

output "helm_release_chart" {
  description = "Name of the ExternalDNS Helm chart."
  value       = helm_release.this.chart
}

output "helm_release_version" {
  description = "Version of the ExternalDNS Helm chart deployed by Terraform."
  value       = helm_release.this.version
}

output "helm_release_status" {
  description = "Current status of the ExternalDNS Helm release."
  value       = helm_release.this.status
}


################################################################################
# ExternalDNS Configuration Outputs
################################################################################

output "hosted_zone_id" {
  description = "Route 53 hosted zone that ExternalDNS is authorized to manage."
  value       = var.hosted_zone_id
}

output "domain_filters" {
  description = "DNS domains that ExternalDNS is configured to manage."
  value       = var.domain_filters
}

output "sources" {
  description = "Kubernetes resource sources watched by ExternalDNS."
  value       = var.sources
}

output "registry" {
  description = "Ownership registry used by ExternalDNS."
  value       = var.registry
}

output "txt_owner_id" {
  description = "TXT ownership identifier used by ExternalDNS."
  value       = var.txt_owner_id
}