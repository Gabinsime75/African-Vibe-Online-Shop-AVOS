# ###############################################################
# # Terraform Version and Providers
# ###############################################################

# terraform {

#   required_version = ">= 1.5.0"

#   required_providers {

#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 6.0"
#     }

#   }

#   #############################################################
#   # Backend
#   #
#   # Backend values should be provided through backend config
#   # during terraform init, not hardcoded in the root module.
#   #############################################################

#   backend "s3" {}

# }


terraform {

  required_version = ">= 1.5.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }

  # backend "s3" {}

}