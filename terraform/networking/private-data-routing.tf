# =============================================================================
# AVOS Network Foundation — Private Data Routing
#
# Creates isolated route tables for the private data subnets. These route
# tables intentionally contain no default route to an Internet or NAT Gateway.
# =============================================================================

resource "aws_route_table" "private_data" {
  for_each = local.private_data_subnets

  vpc_id = aws_vpc.this.id

  tags = {
    Name             = "${local.name_prefix}-private-data-rt-${each.key}"
    NetworkTier      = "private-data"
    AvailabilityZone = each.key
  }
}

resource "aws_route_table_association" "private_data" {
  for_each = aws_subnet.private_data

  subnet_id = each.value.id
  route_table_id = aws_route_table.private_data[
    each.key
  ].id
}