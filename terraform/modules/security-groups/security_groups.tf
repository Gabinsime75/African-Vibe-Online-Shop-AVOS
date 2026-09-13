###############################################################
# Security Groups
###############################################################

resource "aws_security_group" "this" {

  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = each.key
    }
  )

  lifecycle {
    create_before_destroy = true
  }

}