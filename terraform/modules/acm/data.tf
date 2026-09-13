###############################################################
# Route53 Hosted Zone Lookup
###############################################################

data "aws_route53_zone" "this" {

  count = local.lookup_hosted_zone ? 1 : 0

  name = var.hosted_zone_name

  private_zone = false

}