# =============================================================================
# AVOS Network Foundation — Outputs
#
# Exposes stable networking identifiers for downstream Terraform roots such as
# the container platform, databases, platform services, and observability.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the AVOS VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the AVOS VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "Primary IPv4 CIDR block assigned to the AVOS VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the AVOS network foundation."
  value       = var.availability_zones
}

# -----------------------------------------------------------------------------
# Public subnets
# -----------------------------------------------------------------------------

output "public_subnet_ids_by_az" {
  description = "Map of Availability Zone names to public subnet IDs."
  value = {
    for availability_zone, subnet in aws_subnet.public :
    availability_zone => subnet.id
  }
}

output "public_subnet_ids" {
  description = "Ordered list of public subnet IDs."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.public[availability_zone].id
  ]
}

output "public_subnet_cidr_blocks" {
  description = "Map of Availability Zone names to public subnet CIDR blocks."
  value = {
    for availability_zone, subnet in aws_subnet.public :
    availability_zone => subnet.cidr_block
  }
}

# -----------------------------------------------------------------------------
# Private application subnets
# -----------------------------------------------------------------------------

output "private_application_subnet_ids_by_az" {
  description = "Map of Availability Zone names to private application subnet IDs."
  value = {
    for availability_zone, subnet in aws_subnet.private_application :
    availability_zone => subnet.id
  }
}

output "private_application_subnet_ids" {
  description = "Ordered list of private application subnet IDs."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private_application[availability_zone].id
  ]
}

output "private_application_subnet_cidr_blocks" {
  description = "Map of Availability Zone names to private application subnet CIDR blocks."
  value = {
    for availability_zone, subnet in aws_subnet.private_application :
    availability_zone => subnet.cidr_block
  }
}

# -----------------------------------------------------------------------------
# Private data subnets
# -----------------------------------------------------------------------------

output "private_data_subnet_ids_by_az" {
  description = "Map of Availability Zone names to private data subnet IDs."
  value = {
    for availability_zone, subnet in aws_subnet.private_data :
    availability_zone => subnet.id
  }
}

output "private_data_subnet_ids" {
  description = "Ordered list of private data subnet IDs."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private_data[availability_zone].id
  ]
}

output "private_data_subnet_cidr_blocks" {
  description = "Map of Availability Zone names to private data subnet CIDR blocks."
  value = {
    for availability_zone, subnet in aws_subnet.private_data :
    availability_zone => subnet.cidr_block
  }
}

# -----------------------------------------------------------------------------
# Internet access and NAT
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the AVOS VPC."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids_by_az" {
  description = "Map of NAT Gateway placement Availability Zones to NAT Gateway IDs."
  value = {
    for availability_zone, nat_gateway in aws_nat_gateway.this :
    availability_zone => nat_gateway.id
  }
}

output "nat_gateway_public_ips_by_az" {
  description = "Map of NAT Gateway placement Availability Zones to public IP addresses."
  value = {
    for availability_zone, elastic_ip in aws_eip.nat :
    availability_zone => elastic_ip.public_ip
  }
}

# -----------------------------------------------------------------------------
# Route tables
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the route table associated with all public subnets."
  value       = aws_route_table.public.id
}

output "private_application_route_table_ids_by_az" {
  description = "Map of Availability Zones to private application route-table IDs."
  value = {
    for availability_zone, route_table in aws_route_table.private_application :
    availability_zone => route_table.id
  }
}

output "private_data_route_table_ids_by_az" {
  description = "Map of Availability Zones to private data route-table IDs."
  value = {
    for availability_zone, route_table in aws_route_table.private_data :
    availability_zone => route_table.id
  }
}

# -----------------------------------------------------------------------------
# Gateway VPC endpoints
# -----------------------------------------------------------------------------

output "gateway_vpc_endpoint_ids" {
  description = "IDs of the S3 and DynamoDB Gateway VPC endpoints."
  value = {
    s3       = aws_vpc_endpoint.s3.id
    dynamodb = aws_vpc_endpoint.dynamodb.id
  }
}

output "gateway_vpc_endpoint_prefix_list_ids" {
  description = "AWS-managed prefix-list IDs used by the Gateway VPC endpoints."
  value = {
    s3       = aws_vpc_endpoint.s3.prefix_list_id
    dynamodb = aws_vpc_endpoint.dynamodb.prefix_list_id
  }
}

# -----------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = aws_flow_log.this.id
}

output "vpc_flow_log_destination_arn" {
  description = "ARN of the destination receiving VPC Flow Log records."
  value       = aws_flow_log.this.log_destination
}

output "vpc_flow_logs_log_group_name" {
  description = "Name of the CloudWatch Logs group receiving VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "vpc_flow_logs_log_group_arn" {
  description = "ARN of the CloudWatch Logs group receiving VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "vpc_flow_logs_iam_role_arn" {
  description = "ARN of the IAM role used to deliver VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "vpc_flow_logs_kms_key_arn" {
  description = "ARN of the KMS key encrypting the VPC Flow Logs log group."
  value       = aws_kms_key.flow_logs.arn
}

output "vpc_flow_logs_kms_alias" {
  description = "Alias of the KMS key encrypting VPC Flow Logs."
  value       = aws_kms_alias.flow_logs.name
}

# -----------------------------------------------------------------------------
# Network security baseline
# -----------------------------------------------------------------------------

output "default_security_group_id" {
  description = "ID of the restricted default VPC security group."
  value       = aws_default_security_group.this.id
}