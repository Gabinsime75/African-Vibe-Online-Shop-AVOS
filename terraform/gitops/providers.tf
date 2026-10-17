provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project       = "AVOS"
      Environment   = "dev"
      ManagedBy     = "Terraform"
      TerraformRoot = "gitops"
      Phase         = "8"
    }
  }
}

provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name", var.cluster_name,
      "--region", var.aws_region
    ]
  }
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.this.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name", var.cluster_name,
        "--region", var.aws_region
      ]
    }
  }
}
