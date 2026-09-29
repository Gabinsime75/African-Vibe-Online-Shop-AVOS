# =============================================================================
# AVOS Network Foundation — Private Application Routing
#
# Creates one route table per private application subnet. Dev routes all
# outbound traffic through the single NAT Gateway in us-east-2a. The same
# design supports one NAT Gateway per AZ in higher environments.
# =============================================================================

resource "aws_route_table" "private_application" {
  for_each = local.private_application_subnets

  vpc_id = aws_vpc.this.id

  tags = {
    Name             = "${local.name_prefix}-private-app-rt-${each.key}"
    NetworkTier      = "private-application"
    AvailabilityZone = each.key
  }
}

resource "aws_route" "private_application_egress" {
  for_each = local.private_application_subnets

  route_table_id         = aws_route_table.private_application[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[
    local.application_nat_gateway_by_az[each.key]
  ].id
}

resource "aws_route_table_association" "private_application" {
  for_each = aws_subnet.private_application

  subnet_id = each.value.id
  route_table_id = aws_route_table.private_application[
    each.key
  ].id
}