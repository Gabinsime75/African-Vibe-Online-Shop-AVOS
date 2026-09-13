###############################################################
# Application Load Balancer Listeners
###############################################################

resource "aws_lb_listener" "this" {

  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn

  port     = each.value.port
  protocol = each.value.protocol

  ssl_policy      = try(each.value.ssl_policy, null)
  certificate_arn = try(each.value.certificate_arn, null)
  alpn_policy     = try(each.value.alpn_policy, null)

  #############################################################
  # Default Action - Forward
  #############################################################

  dynamic "default_action" {

    for_each = try(each.value.default_action.type, "") == "forward" ? [each.value.default_action] : []

    content {

      type = "forward"

      dynamic "forward" {

        for_each = [default_action.value]

        content {

          #######################################################
          # Weighted Target Groups
          #######################################################

          dynamic "target_group" {

            for_each = forward.value.target_groups

            content {

              arn    = aws_lb_target_group.this[target_group.value.name].arn
              weight = try(target_group.value.weight, 1)

            }

          }

          #######################################################
          # Stickiness
          #######################################################

          dynamic "stickiness" {

            for_each = try(forward.value.stickiness.enabled, false) ? [forward.value.stickiness] : []

            content {

              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration

            }

          }

        }

      }

    }

  }

  #############################################################
  # Default Action - Redirect
  #############################################################

  dynamic "default_action" {

    for_each = try(each.value.default_action.type, "") == "redirect" ? [each.value.default_action] : []

    content {

      type = "redirect"

      redirect {

        protocol    = try(default_action.value.protocol, "#{protocol}")
        port        = try(default_action.value.port, "#{port}")
        host        = try(default_action.value.host, "#{host}")
        path        = try(default_action.value.path, "/#{path}")
        query       = try(default_action.value.query, "#{query}")
        status_code = default_action.value.status_code

      }

    }

  }

  #############################################################
  # Default Action - Fixed Response
  #############################################################

  dynamic "default_action" {

    for_each = try(each.value.default_action.type, "") == "fixed-response" ? [each.value.default_action] : []

    content {

      type = "fixed-response"

      fixed_response {

        content_type = default_action.value.content_type
        message_body = try(default_action.value.message_body, null)
        status_code  = default_action.value.status_code

      }

    }

  }

  #   tags = merge(
  #     local.common_tags,
  #     {
  #       Name = "${local.name_prefix}-${each.key}"
  #     }
  #   )

}