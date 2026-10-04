# =============================================================================
# AVOS Container Platform — AWS Provider
#
# Configures the AWS Region and applies mandatory AVOS tags to supported
# resources created by this Terraform root.
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "kubernetes" {
  host = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.current.token
}

provider "helm" {
  kubernetes {
    host = aws_eks_cluster.this.endpoint

    cluster_ca_certificate = base64decode(
      aws_eks_cluster.this.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.current.token
  }
}