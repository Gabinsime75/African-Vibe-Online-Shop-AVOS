# =============================================================================
# AVOS Network Foundation — NAT Gateways
#
# Allocates public Elastic IP addresses and creates NAT Gateways in the selected
# public subnets. Dev uses one NAT Gateway; higher environments can use one per
# Availability Zone by setting nat_gateway_mode to per_az.
# =============================================================================

resource "aws_eip" "nat" {
  for_each = local.nat_gateway_availability_zones

  domain = "vpc"

  tags = {
    Name             = "${local.name_prefix}-nat-eip-${each.key}"
    NetworkTier      = "public"
    AvailabilityZone = each.key
  }
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_availability_zones

  allocation_id     = aws_eip.nat[each.key].id
  subnet_id         = aws_subnet.public[each.key].id
  connectivity_type = "public"

  tags = {
    Name             = "${local.name_prefix}-nat-${each.key}"
    NetworkTier      = "public"
    AvailabilityZone = each.key
  }

  depends_on = [
    aws_internet_gateway.this
  ]
}