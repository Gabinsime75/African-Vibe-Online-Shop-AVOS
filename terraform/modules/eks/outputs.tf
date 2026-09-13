output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_id" {
  description = "ID of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_role_arn" {
  description = "IAM role ARN used by the EKS control plane."
  value       = aws_iam_role.cluster.arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EKS secrets encryption."
  value       = var.create_kms_key ? aws_kms_key.eks[0].arn : var.kms_key_arn
}

output "kms_alias_name" {
  description = "Alias name of the EKS KMS key."
  value       = var.create_kms_key ? aws_kms_alias.eks[0].name : null
}

output "node_group_names" {
  description = "Names of the EKS managed node groups."
  value       = { for k, v in aws_eks_node_group.this : k => v.node_group_name }
}

output "node_group_arns" {
  description = "ARNs of the EKS managed node groups."
  value       = { for k, v in aws_eks_node_group.this : k => v.arn }
}

output "node_group_role_arns" {
  description = "IAM role ARNs used by EKS managed node groups."
  value       = { for k, v in aws_iam_role.node_group : k => v.arn }
}

output "installed_addons" {
  description = "AWS managed EKS add-ons installed."

  value = {
    vpc_cni        = try(aws_eks_addon.vpc_cni[0].addon_name, null)
    coredns        = try(aws_eks_addon.coredns[0].addon_name, null)
    kube_proxy     = try(aws_eks_addon.kube_proxy[0].addon_name, null)
    ebs_csi_driver = try(aws_eks_addon.ebs_csi[0].addon_name, null)
    pod_identity   = try(aws_eks_addon.pod_identity_agent[0].addon_name, null)
  }
}

output "access_entry_principals" {
  description = "Principal ARNs configured as EKS access entries."
  value       = { for k, v in aws_eks_access_entry.this : k => v.principal_arn }
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider."
  value       = var.enable_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : null
}

output "oidc_provider_url" {
  description = "URL of the IAM OIDC provider."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cloudwatch_log_group_name" {
  description = "Name of the EKS control plane CloudWatch Log Group."
  value       = var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.cluster[0].name : null
}

output "ebs_csi_pod_identity_role_arn" {
  description = "IAM role ARN used by the EBS CSI controller through EKS Pod Identity."

  value = (
    var.enable_ebs_csi_driver && var.create_ebs_csi_pod_identity
    ? aws_iam_role.ebs_csi_pod_identity[0].arn
    : null
  )
}

output "ebs_csi_pod_identity_association_id" {
  description = "ID of the EBS CSI Pod Identity association."

  value = (
    var.enable_ebs_csi_driver && var.create_ebs_csi_pod_identity
    ? aws_eks_pod_identity_association.ebs_csi[0].association_id
    : null
  )
}