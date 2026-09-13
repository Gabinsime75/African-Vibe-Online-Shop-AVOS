###############################################################
# VPC Outputs
###############################################################

output "vpc_id" {
  description = "ID of the VPC created by the networking root."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = module.vpc.private_db_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = module.vpc.nat_gateway_ids
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = module.vpc.private_route_table_ids
}

###############################################################
# Security Group Outputs
###############################################################

output "security_group_ids" {
  description = "Map of security group IDs created by the security-groups module."
  value       = module.security_groups.security_group_ids
}

output "alb_security_group_id" {
  description = "Security group ID attached to the Application Load Balancer."
  value       = module.security_groups.security_group_ids["alb"]
}

###############################################################
# ACM Outputs
###############################################################

output "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener."
  value       = var.enable_https ? module.acm[0].certificate_arn : null
}

output "validated_certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = var.enable_https ? module.acm[0].validated_certificate_arn : null
}

output "certificate_domain_name" {
  description = "Primary domain name on the ACM certificate."
  value       = var.enable_https ? module.acm[0].certificate_domain_name : null
}

output "domain_validation_options" {
  description = "ACM DNS validation records for the requested certificate."
  value       = var.enable_https ? module.acm[0].domain_validation_options : null
}

output "validation_record_fqdns" {
  description = "Route53 DNS validation record FQDNs created for ACM."
  value       = var.enable_https ? module.acm[0].validation_record_fqdns : []
}

###############################################################
# ALB Outputs
###############################################################

output "alb_id" {
  description = "ID of the Application Load Balancer."
  value       = module.alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "Route53 hosted zone ID of the Application Load Balancer."
  value       = module.alb.zone_id
}

output "alb_listener_arns" {
  description = "Map of ALB listener ARNs."
  value       = module.alb.listener_arns
}

output "alb_target_group_arns" {
  description = "Map of ALB target group ARNs."
  value       = module.alb.target_group_arns
}

output "app_target_group_arn" {
  description = "ARN of the application target group."
  value       = module.alb.target_group_arns["app"]
}

output "app_target_group_name" {
  description = "Name of the application target group."
  value       = module.alb.target_group_names["app"]
}

output "istio_ingress_target_group_arn" {
  description = "ARN of the target group used by the Istio ingress gateway."
  value       = module.alb.target_group_arns["istio_ingress"]
}

output "istio_ingress_target_group_name" {
  description = "Name of the target group used by the Istio ingress gateway."
  value       = module.alb.target_group_names["istio_ingress"]
}

output "istio_ingress_target_group_id" {
  description = "ID of the target group used by the Istio ingress gateway."
  value       = module.alb.target_group_ids["istio_ingress"]
}

###############################################################
# Route53 Outputs
###############################################################

output "hosted_zone_id" {
  description = "Route53 hosted zone ID used by the networking root."
  value       = module.route53.hosted_zone_id
}

output "hosted_zone_name" {
  description = "Route53 hosted zone name used by the networking root."
  value       = module.route53.hosted_zone_name
}

output "route53_record_fqdns" {
  description = "FQDNs of Route53 records created by the networking root."
  value       = module.route53.record_fqdns
}

output "route53_record_names" {
  description = "Names of Route53 records created by the networking root."
  value       = module.route53.record_names
}

###############################################################
# Application Endpoint Outputs
###############################################################

output "application_url" {
  description = "Primary application URL."
  value       = var.enable_https ? "https://${var.app_domain_name}" : "http://${var.app_domain_name}"
}

output "alb_health_check_path" {
  description = "Health check path configured for the application target group."
  value       = var.app_health_check_path
}