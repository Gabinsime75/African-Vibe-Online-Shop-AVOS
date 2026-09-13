###############################################################
# Application Load Balancer Target Groups
###############################################################

# resource "aws_lb_target_group" "this" {

#   for_each = var.target_groups

#   #############################################################
#   # Basic Configuration
#   #############################################################

#   name   = substr("${var.name}-${each.key}", 0, 32)
#   vpc_id = var.vpc_id

#   port        = each.value.port
#   protocol    = each.value.protocol
#   target_type = each.value.target_type

#   protocol_version = try(each.value.protocol_version, null)

#   ip_address_type = try(each.value.ip_address_type, null)

#   #############################################################
#   # Connection Handling
#   #############################################################

#   deregistration_delay = try(each.value.deregistration_delay, null)

#   slow_start = try(each.value.slow_start, null)

#   load_balancing_algorithm_type = try(
#     each.value.load_balancing_algorithm_type,
#     null
#   )

#   #############################################################
#   # Health Check
#   #############################################################

#   dynamic "health_check" {

#     for_each = each.value.health_check != null ? [each.value.health_check] : []

#     content {

#       enabled = try(health_check.value.enabled, true)

#       protocol = try(health_check.value.protocol, null)

#       port = try(health_check.value.port, null)

#       path = try(health_check.value.path, null)

#       matcher = try(health_check.value.matcher, null)

#       interval = try(health_check.value.interval, null)

#       timeout = try(health_check.value.timeout, null)

#       healthy_threshold = try(
#         health_check.value.healthy_threshold,
#         null
#       )

#       unhealthy_threshold = try(
#         health_check.value.unhealthy_threshold,
#         null
#       )

#     }

#   }

#   #############################################################
#   # Stickiness
#   #############################################################

#   dynamic "stickiness" {

#     for_each = try(each.value.stickiness, null) != null ? [each.value.stickiness] : []

#     content {

#       enabled = try(stickiness.value.enabled, false)

#       type = try(stickiness.value.type, "lb_cookie")

#       cookie_duration = try(stickiness.value.cookie_duration, null)

#       cookie_name = try(stickiness.value.cookie_name, null)

#     }

#   }
#   #############################################################
#   # Lambda
#   #############################################################

#   lambda_multi_value_headers_enabled = try(
#     each.value.lambda_multi_value_headers_enabled,
#     null
#   )

#   #############################################################
#   # Resource Tags
#   #############################################################

#   tags = merge(
#     local.common_tags,
#     try(each.value.tags, {}),
#     {
#       Name = substr("${var.name}-${each.key}", 0, 32)
#     }
#   )

# }

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name = coalesce(
    try(each.value.name, null),
    substr("${var.name}-${each.key}", 0, 32)
  )

  vpc_id = var.vpc_id

  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type

  protocol_version = try(each.value.protocol_version, null)
  ip_address_type  = try(each.value.ip_address_type, null)

  deregistration_delay = try(each.value.deregistration_delay, null)
  slow_start           = try(each.value.slow_start, null)

  load_balancing_algorithm_type = try(
    each.value.load_balancing_algorithm_type,
    null
  )

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []

    content {
      enabled             = try(health_check.value.enabled, true)
      protocol            = try(health_check.value.protocol, null)
      port                = try(health_check.value.port, null)
      path                = try(health_check.value.path, null)
      matcher             = try(health_check.value.matcher, null)
      interval            = try(health_check.value.interval, null)
      timeout             = try(health_check.value.timeout, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  dynamic "stickiness" {
    for_each = try(each.value.stickiness, null) != null ? [each.value.stickiness] : []

    content {
      enabled         = try(stickiness.value.enabled, false)
      type            = try(stickiness.value.type, "lb_cookie")
      cookie_duration = try(stickiness.value.cookie_duration, null)
      cookie_name     = try(stickiness.value.cookie_name, null)
    }
  }

  lambda_multi_value_headers_enabled = try(
    each.value.lambda_multi_value_headers_enabled,
    null
  )

  tags = merge(
    local.common_tags,
    try(each.value.tags, {}),
    {
      Name = coalesce(
        try(each.value.name, null),
        substr("${var.name}-${each.key}", 0, 32)
      )
    }
  )
}