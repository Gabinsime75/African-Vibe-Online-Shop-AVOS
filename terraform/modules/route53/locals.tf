###############################################################
# Local Values
###############################################################

locals {

  #############################################################
  # Hosted Zone Resolution
  #############################################################

  hosted_zone_name_normalized = trimsuffix(var.hosted_zone_name, ".")

  effective_hosted_zone_name = "${local.hosted_zone_name_normalized}."

  use_existing_hosted_zone = (
    var.create_hosted_zone == false &&
    var.hosted_zone_id != null
  )

  lookup_existing_hosted_zone = (
    var.create_hosted_zone == false &&
    var.hosted_zone_id == null
  )

  #############################################################
  # Effective Hosted Zone ID
  #############################################################

  hosted_zone_id = (
    var.create_hosted_zone
    ? try(aws_route53_zone.this[0].zone_id, null)
    : (
      var.hosted_zone_id != null
      ? var.hosted_zone_id
      : try(data.aws_route53_zone.this[0].zone_id, null)
    )
  )

  #############################################################
  # Resource Tags
  #############################################################

  common_tags = merge(
    var.tags,
    {
      Name = local.hosted_zone_name_normalized
    }
  )

}