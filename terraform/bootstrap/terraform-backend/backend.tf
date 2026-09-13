terraform {
  backend "s3" {
    bucket       = "cloudhustler-tfstate-dev"
    key          = "bootstrap/backend/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}