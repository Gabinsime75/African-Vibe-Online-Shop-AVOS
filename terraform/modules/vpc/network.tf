###############################################
# VPC
###############################################

resource "aws_vpc" "this" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-vpc"

    }

  )

}

###############################################
# Internet Gateway
###############################################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-igw"

    }

  )

}