# =============================================================================
# AVOS Network Foundation — Subnets
#
# Creates public, private application, and private data subnets across three
# Availability Zones. Routing is configured separately.
# =============================================================================

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr

  map_public_ip_on_launch = false

  tags = {
    Name                     = each.value.name
    NetworkTier              = each.value.tier
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_application" {
  for_each = local.private_application_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr

  map_public_ip_on_launch = false

  tags = {
    Name                              = each.value.name
    NetworkTier                       = each.value.tier
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_data" {
  for_each = local.private_data_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr

  map_public_ip_on_launch = false

  tags = {
    Name        = each.value.name
    NetworkTier = each.value.tier
  }
}