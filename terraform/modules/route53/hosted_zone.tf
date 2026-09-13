###############################################################
# Route53 Hosted Zone
###############################################################

resource "aws_route53_zone" "this" {

  count = var.create_hosted_zone ? 1 : 0

  name = local.effective_hosted_zone_name

  comment = var.comment

  force_destroy = var.force_destroy

  #############################################################
  # Private Hosted Zone VPC Associations
  #############################################################

  dynamic "vpc" {

    for_each = var.private_zone ? var.vpcs : []

    content {

      vpc_id = vpc.value.vpc_id

      vpc_region = try(vpc.value.vpc_region, null)

    }

  }

  #############################################################
  # Resource Tags
  #############################################################

  tags = local.common_tags

}