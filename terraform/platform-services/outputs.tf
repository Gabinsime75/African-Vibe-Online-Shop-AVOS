# =============================================================================
# AVOS Platform Services — Foundation Outputs
# =============================================================================

output "cluster_name" {
  description = "Existing EKS cluster used by the platform controllers."
  value       = data.aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API endpoint of the existing EKS cluster."
  value       = data.aws_eks_cluster.this.endpoint
}

output "vpc_id" {
  description = "Existing VPC containing the EKS cluster."
  value       = data.aws_vpc.this.id
}
