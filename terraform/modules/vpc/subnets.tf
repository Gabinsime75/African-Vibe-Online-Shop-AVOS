###############################################
# Public Subnets
###############################################

resource "aws_subnet" "public" {

  for_each = {

    for index, az in local.availability_zones :

    az => {

      cidr = var.public_subnet_cidrs[index]

    }

  }

  vpc_id = aws_vpc.this.id

  availability_zone = each.key

  cidr_block = each.value.cidr

  map_public_ip_on_launch = true

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-public-${substr(each.key, -1, 1)}"

      Tier = "Public"

    }

  )

}

###############################################
# Private Application Subnets
###############################################

resource "aws_subnet" "private_app" {
  for_each = {
    for index, az in local.availability_zones :
    az => {
      cidr = var.private_app_subnet_cidrs[index]
    }
  }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.cidr

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-app-${substr(each.key, -1, 1)}"
      Tier = "Application"

      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery"          = "cloudhusller-commerce-platform-dev-eks"
    }
  )
}

###############################################
# Private Database Subnets
###############################################

resource "aws_subnet" "private_db" {

  for_each = {

    for index, az in local.availability_zones :

    az => {

      cidr = var.private_db_subnet_cidrs[index]

    }

  }

  vpc_id = aws_vpc.this.id

  availability_zone = each.key

  cidr_block = each.value.cidr

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-private-db-${substr(each.key, -1, 1)}"

      Tier = "Database"

    }

  )

}