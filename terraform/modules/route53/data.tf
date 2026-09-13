###############################################################
# Existing Route53 Hosted Zone Lookup
###############################################################

data "aws_route53_zone" "this" {

  count = local.lookup_existing_hosted_zone ? 1 : 0

  name = local.effective_hosted_zone_name

  private_zone = var.private_zone

}