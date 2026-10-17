provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = ["396913735153"]

  default_tags {
    tags = {
      Project     = "AVOS"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Component   = "CISupplyChain"
    }
  }
}
