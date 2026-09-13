locals {
  cluster_name = var.cluster_name

  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "eks"
    }
  )
}