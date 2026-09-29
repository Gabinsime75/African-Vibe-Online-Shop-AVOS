# =============================================================================
# AVOS Network Foundation — Architecture Checks
#
# Validates relationships between Availability Zones, subnet maps, and CIDR
# allocations before Terraform creates network resources.
# =============================================================================

check "subnet_availability_zone_keys" {
  assert {
    condition = (
      toset(keys(var.public_subnet_cidrs)) == toset(var.availability_zones) &&
      toset(keys(var.private_application_subnet_cidrs)) == toset(var.availability_zones) &&
      toset(keys(var.private_data_subnet_cidrs)) == toset(var.availability_zones)
    )

    error_message = "Every subnet map must contain exactly the approved Availability Zone keys."
  }
}

check "unique_subnet_cidrs" {
  assert {
    condition = (
      length(distinct(local.all_subnet_cidrs)) ==
      length(local.all_subnet_cidrs)
    )

    error_message = "Every AVOS subnet must have a unique CIDR block."
  }
}

check "approved_subnet_cidr_plan" {
  assert {
    condition = (
      var.public_subnet_cidrs == tomap({
        for index, availability_zone in var.availability_zones :
        availability_zone => cidrsubnet(var.vpc_cidr, 4, index)
      }) &&
      var.private_application_subnet_cidrs == tomap({
        for index, availability_zone in var.availability_zones :
        availability_zone => cidrsubnet(var.vpc_cidr, 4, index + 4)
      }) &&
      var.private_data_subnet_cidrs == tomap({
        for index, availability_zone in var.availability_zones :
        availability_zone => cidrsubnet(var.vpc_cidr, 4, index + 8)
      })
    )

    error_message = "Subnet CIDRs must match the approved AVOS /20 allocation derived from the VPC CIDR."
  }
}