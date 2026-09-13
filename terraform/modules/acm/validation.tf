###############################################################
# Route53 DNS Validation Records
###############################################################

locals {

  #############################################################
  # Static Validation Domains
  #
  # Terraform requires for_each keys to be known during plan.
  # ACM-generated DNS record names are not known until apply,
  # so we use the input domains as stable keys instead.
  #
  # replace(domain, "*.", "") prevents duplicate Route53 records
  # when both example.com and *.example.com are on the same cert.
  #############################################################

  validation_domains = distinct([
    for domain in local.certificate_domains :
    replace(domain, "*.", "")
  ])

}

resource "aws_route53_record" "validation" {

  for_each = local.create_validation_records ? {
    for domain in local.validation_domains :
    domain => domain
  } : {}

  zone_id = coalesce(
    var.hosted_zone_id,
    try(data.aws_route53_zone.this[0].zone_id, null)
  )

  name = one([
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_name
    if replace(option.domain_name, "*.", "") == each.value
  ])

  type = one([
    for option in aws_acm_certificate.this.domain_validation_options :
    option.resource_record_type
    if replace(option.domain_name, "*.", "") == each.value
  ])

  records = [
    one([
      for option in aws_acm_certificate.this.domain_validation_options :
      option.resource_record_value
      if replace(option.domain_name, "*.", "") == each.value
    ])
  ]

  ttl = var.validation_record_ttl

  allow_overwrite = var.allow_overwrite_validation_records

}

###############################################################
# ACM Certificate Validation
###############################################################

resource "aws_acm_certificate_validation" "this" {

  count = local.create_validation_records ? 1 : 0

  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]

  timeouts {

    create = "45m"

  }

}