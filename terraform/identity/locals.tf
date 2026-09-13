#############################################
# Local Values
#############################################

locals {

  ###########################################
  # Common Tags
  ###########################################

  common_tags = {

    Project     = "CloudHustler Commerce Platform"
    Environment = "Management"
    ManagedBy   = "Terraform"
    Owner       = "Cloud Platform Team"

  }

}