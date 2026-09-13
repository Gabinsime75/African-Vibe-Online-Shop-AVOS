###############################################
# VPC
###############################################

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

###############################################
# Availability Zones
###############################################

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = local.availability_zones
}

###############################################
# Public Subnets
###############################################

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}

###############################################
# Private Application Subnets
###############################################

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value = [
    for subnet in aws_subnet.private_app :
    subnet.id
  ]
}

###############################################
# Private Database Subnets
###############################################

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value = [
    for subnet in aws_subnet.private_db :
    subnet.id
  ]
}

###############################################
# Internet Gateway
###############################################

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.this.id
}

###############################################
# NAT Gateways
###############################################

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value = [
    for nat in aws_nat_gateway.this :
    nat.id
  ]
}

###############################################
# Route Tables
###############################################

output "public_route_table_id" {
  description = "Public Route Table ID."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private Route Table IDs."
  value = {
    for az, rt in aws_route_table.private :
    az => rt.id
  }
}