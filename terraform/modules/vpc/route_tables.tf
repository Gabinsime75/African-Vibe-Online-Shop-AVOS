###############################################
# Public Route Table
###############################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )

}

###############################################
# Public Internet Route
###############################################

resource "aws_route" "public_internet" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id

}

###############################################
# Private Route Tables
###############################################

resource "aws_route_table" "private" {

  for_each = {
    for index, az in local.availability_zones :
    az => index
  }

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-${substr(each.key, -1, 1)}-rt"
    }
  )

}

###############################################
# Private Internet Routes
###############################################

resource "aws_route" "private_internet" {

  for_each = aws_route_table.private

  route_table_id = each.value.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[
    var.single_nat_gateway
    ? 0
    : index(local.availability_zones, each.key)
  ].id

}

###############################################
# Public Route Table Associations
###############################################

resource "aws_route_table_association" "public" {

  for_each = aws_subnet.public

  subnet_id = each.value.id

  route_table_id = aws_route_table.public.id

}

###############################################
# Private Application Route Table Associations
###############################################

resource "aws_route_table_association" "private_app" {

  for_each = aws_subnet.private_app

  subnet_id = each.value.id

  route_table_id = aws_route_table.private[each.key].id

}

###############################################
# Private Database Route Table Associations
###############################################

resource "aws_route_table_association" "private_db" {

  for_each = aws_subnet.private_db

  subnet_id = each.value.id

  route_table_id = aws_route_table.private[each.key].id

}