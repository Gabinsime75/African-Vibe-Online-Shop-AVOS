output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID created by EKS for the cluster."
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster."
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "node_group_names" {
  description = "Names of the EKS managed node groups."
  value       = module.eks.node_group_names
}

output "node_group_role_arns" {
  description = "IAM role ARNs used by EKS managed node groups."
  value       = module.eks.node_group_role_arns
}

output "installed_addons" {
  description = "AWS managed EKS add-ons installed."
  value       = module.eks.installed_addons
}

output "ebs_csi_pod_identity_role_arn" {
  description = "IAM role ARN used by the EBS CSI controller through EKS Pod Identity."
  value       = module.eks.ebs_csi_pod_identity_role_arn
}

output "ebs_csi_pod_identity_association_id" {
  description = "ID of the EBS CSI Pod Identity association."
  value       = module.eks.ebs_csi_pod_identity_association_id
}