output "namespace" {
  description = "Namespace in which Cert-Manager is installed."
  value       = var.namespace
}

output "helm_release_name" {
  description = "Cert-Manager Helm release name."
  value       = helm_release.cert_manager.name
}

output "helm_release_status" {
  description = "Cert-Manager Helm release status."
  value       = helm_release.cert_manager.status
}

output "iam_role_arn" {
  description = "IAM role used by Cert-Manager through EKS Pod Identity."
  value       = aws_iam_role.cert_manager.arn
}

output "iam_policy_arn" {
  description = "IAM policy granting Cert-Manager access to Route 53."
  value       = aws_iam_policy.cert_manager.arn
}

output "pod_identity_association_id" {
  description = "EKS Pod Identity association ID for Cert-Manager."
  value       = aws_eks_pod_identity_association.cert_manager.association_id
}

output "production_cluster_issuer_name" {
  description = "Let's Encrypt production ClusterIssuer name."
  value       = var.create_cluster_issuers ? var.production_cluster_issuer_name : null
}

output "staging_cluster_issuer_name" {
  description = "Let's Encrypt staging ClusterIssuer name."
  value = (
    var.create_cluster_issuers &&
    var.create_staging_cluster_issuer
  ) ? var.staging_cluster_issuer_name : null
}