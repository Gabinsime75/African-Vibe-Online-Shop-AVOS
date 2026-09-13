###############################################################
# Flatten Security Group Rules
###############################################################

locals {

  #############################################################
  # Ingress Rules
  #############################################################

  ingress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for rule_index, rule in try(sg.ingress_rules, []) : {
        key               = "${sg_key}-ingress-${rule_index}"
        security_group_id = aws_security_group.this[sg_key].id

        description = try(rule.description, null)
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol

        cidr_ipv4 = try(
          coalesce(
            try(rule.cidr_ipv4, null),
            try(rule.cidr_blocks[0], null)
          ),
          null
        )

        cidr_ipv6 = try(
          coalesce(
            try(rule.cidr_ipv6, null),
            try(rule.ipv6_cidr_blocks[0], null)
          ),
          null
        )

        prefix_list_id = try(
          coalesce(
            try(rule.prefix_list_id, null),
            try(rule.prefix_list_ids[0], null)
          ),
          null
        )

        referenced_security_group_id = try(
          rule.referenced_security_group_id,
          null
        )
      }
    ]
  ])

  #############################################################
  # Egress Rules
  #############################################################

  egress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for rule_index, rule in try(sg.egress_rules, []) : {
        key               = "${sg_key}-egress-${rule_index}"
        security_group_id = aws_security_group.this[sg_key].id

        description = try(rule.description, null)
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol

        cidr_ipv4 = try(
          coalesce(
            try(rule.cidr_ipv4, null),
            try(rule.cidr_blocks[0], null)
          ),
          null
        )

        cidr_ipv6 = try(
          coalesce(
            try(rule.cidr_ipv6, null),
            try(rule.ipv6_cidr_blocks[0], null)
          ),
          null
        )

        prefix_list_id = try(
          coalesce(
            try(rule.prefix_list_id, null),
            try(rule.prefix_list_ids[0], null)
          ),
          null
        )

        referenced_security_group_id = try(
          rule.referenced_security_group_id,
          null
        )
      }
    ]
  ])

}

###############################################################
# Ingress Rules
###############################################################

resource "aws_vpc_security_group_ingress_rule" "this" {

  for_each = {
    for rule in local.ingress_rules :
    rule.key => rule
  }

  security_group_id = each.value.security_group_id

  description = each.value.description

  ip_protocol = each.value.protocol

  from_port = each.value.protocol == "-1" ? null : each.value.from_port
  to_port   = each.value.protocol == "-1" ? null : each.value.to_port

  cidr_ipv4 = each.value.cidr_ipv4

  cidr_ipv6 = each.value.cidr_ipv6

  prefix_list_id = each.value.prefix_list_id

  referenced_security_group_id = each.value.referenced_security_group_id

}

###############################################################
# Egress Rules
###############################################################

resource "aws_vpc_security_group_egress_rule" "this" {

  for_each = {
    for rule in local.egress_rules :
    rule.key => rule
  }

  security_group_id = each.value.security_group_id

  description = each.value.description

  ip_protocol = each.value.protocol

  from_port = each.value.protocol == "-1" ? null : each.value.from_port
  to_port   = each.value.protocol == "-1" ? null : each.value.to_port

  cidr_ipv4 = each.value.cidr_ipv4

  cidr_ipv6 = each.value.cidr_ipv6

  prefix_list_id = each.value.prefix_list_id

  referenced_security_group_id = each.value.referenced_security_group_id

}