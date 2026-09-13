###############################################
# Elastic IPs
###############################################

resource "aws_eip" "nat" {

  count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : var.az_count
  ) : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

}

###############################################
# NAT Gateways
###############################################

resource "aws_nat_gateway" "this" {

  count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : var.az_count
  ) : 0

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = values(aws_subnet.public)[
    var.single_nat_gateway ? 0 : count.index
  ].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${count.index + 1}"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]

}