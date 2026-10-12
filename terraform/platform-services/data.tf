# =============================================================================
# AVOS Platform Services — Existing Infrastructure Lookups
# =============================================================================

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}
