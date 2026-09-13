###############################################################
# Hosted Zone
###############################################################

output "hosted_zone_id" {
  description = "Route53 hosted zone ID used by this module."
  value       = local.hosted_zone_id
}

output "hosted_zone_name" {
  description = "Route53 hosted zone name."
  value       = local.effective_hosted_zone_name
}

output "hosted_zone_arn" {
  description = "ARN of the Route53 hosted zone when created by this module."

  value = try(
    aws_route53_zone.this[0].arn,
    null
  )
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone when created by this module."

  value = try(
    aws_route53_zone.this[0].name_servers,
    null
  )
}

###############################################################
# DNS Records
###############################################################

output "record_names" {
  description = "Map of Route53 record names."

  value = {
    for key, record in aws_route53_record.this :
    key => record.name
  }
}

output "record_fqdns" {
  description = "Map of Route53 record FQDNs."

  value = {
    for key, record in aws_route53_record.this :
    key => record.fqdn
  }
}

output "record_types" {
  description = "Map of Route53 record types."

  value = {
    for key, record in aws_route53_record.this :
    key => record.type
  }
}

###############################################################
# Health Checks
###############################################################

output "health_check_ids" {
  description = "Map of Route53 health check IDs."

  value = {
    for key, health_check in aws_route53_health_check.this :
    key => health_check.id
  }
}

output "health_check_arns" {
  description = "Map of Route53 health check ARNs."

  value = {
    for key, health_check in aws_route53_health_check.this :
    key => health_check.arn
  }
}