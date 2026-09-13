###############################################################
# Local Values
###############################################################

locals {

  #############################################################
  # Certificate Validation
  #############################################################

  use_dns_validation = upper(var.validation_method) == "DNS"

  use_email_validation = upper(var.validation_method) == "EMAIL"

  #############################################################
  # Route53 Integration
  #############################################################

  use_existing_hosted_zone = (
    local.use_dns_validation &&
    var.hosted_zone_id != null
  )

  lookup_hosted_zone = (
    local.use_dns_validation &&
    var.hosted_zone_id == null &&
    var.hosted_zone_name != null
  )

  create_validation_records = (
    local.use_dns_validation &&
    var.create_route53_records
  )

  #############################################################
  # Certificate Domains
  #############################################################

  certificate_domains = distinct(
    concat(
      [var.domain_name],
      var.subject_alternative_names
    )
  )

  #############################################################
  # Resource Tags
  #############################################################

  common_tags = merge(
    var.tags,
    {
      Name = var.domain_name
    }
  )

}