###############################################
# Local Values
###############################################

locals {

  #############################################
  # Naming
  #############################################

  name_prefix = "${var.project_name}-${var.environment}"

  #############################################
  # Availability Zones
  #############################################

  availability_zones = slice(

    data.aws_availability_zones.available.names,

    0,

    var.az_count

  )

  #############################################
  # Common Tags
  #############################################

  common_tags = merge(

    var.tags,

    {

      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"

    }

  )

}