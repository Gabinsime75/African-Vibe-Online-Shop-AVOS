#############################################
# Local Values
#############################################

locals {
  organizational_units = {
    security        = "Security"
    infrastructure  = "Infrastructure"
    shared_services = "Shared Services"
    logging         = "Logging"
    nonproduction   = "NonProduction"
    development     = "Development"
    testing         = "Testing"
    staging         = "Staging"
    production      = "Production"
    suspended       = "Suspended"

  }

  common_tags = {

    Project     = "CloudHustler Commerce Platform"
    Environment = "Management"
    ManagedBy   = "Terraform"
    Owner       = "Cloud Platform Team"

  }

}