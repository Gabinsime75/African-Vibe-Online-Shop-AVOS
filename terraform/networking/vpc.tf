# =============================================================================
# AVOS Network Foundation — Virtual Private Cloud
#
# Creates the regional network boundary for AVOS with DNS capabilities,
# address-usage monitoring, standardized tags, and architecture safeguards.
# =============================================================================

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_network_address_usage_metrics = true

  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name        = "${local.name_prefix}-vpc"
    Network     = "AVOS"
    NetworkTier = "foundation"
  }

  lifecycle {
    precondition {
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

      error_message = "The configured subnet CIDRs do not match the approved AVOS network allocation."
    }
  }
}