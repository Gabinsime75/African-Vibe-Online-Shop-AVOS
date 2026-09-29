# =============================================================================
# AVOS Network Foundation — Local Values
#
# Normalizes naming, mandatory tags, subnet definitions, and NAT placement
# so network resources consume consistent structures.
# =============================================================================

locals {
  name_prefix         = "${var.project_name}-${var.environment}"
  flow_log_group_name = "/aws/vpc/flow-logs/${local.name_prefix}"

  mandatory_tags = {
    Project       = upper(var.project_name)
    Environment   = var.environment
    ManagedBy     = "Terraform"
    TerraformRoot = "networking"
  }

  common_tags = merge(
    var.additional_tags,
    local.mandatory_tags
  )

  public_subnets = {
    for availability_zone, cidr in var.public_subnet_cidrs :
    availability_zone => {
      availability_zone = availability_zone
      cidr              = cidr
      tier              = "public"
      name              = "${local.name_prefix}-public-${availability_zone}"
    }
  }

  private_application_subnets = {
    for availability_zone, cidr in var.private_application_subnet_cidrs :
    availability_zone => {
      availability_zone = availability_zone
      cidr              = cidr
      tier              = "private-application"
      name              = "${local.name_prefix}-private-app-${availability_zone}"
    }
  }

  private_data_subnets = {
    for availability_zone, cidr in var.private_data_subnet_cidrs :
    availability_zone => {
      availability_zone = availability_zone
      cidr              = cidr
      tier              = "private-data"
      name              = "${local.name_prefix}-private-data-${availability_zone}"
    }
  }

  nat_gateway_availability_zones = var.nat_gateway_mode == "single" ? toset([
    var.availability_zones[0]
  ]) : toset(var.availability_zones)

  application_nat_gateway_by_az = {
    for availability_zone in var.availability_zones :
    availability_zone => (
      var.nat_gateway_mode == "single"
      ? var.availability_zones[0]
      : availability_zone
    )
  }

  all_subnet_cidrs = concat(
    values(var.public_subnet_cidrs),
    values(var.private_application_subnet_cidrs),
    values(var.private_data_subnet_cidrs)
  )
}