###############################################################
# Application Load Balancer Listener Rules
###############################################################

resource "aws_lb_listener_rule" "this" {

  for_each = var.listener_rules

  #############################################################
  # Rule Configuration
  #############################################################

  listener_arn = aws_lb_listener.this[each.value.listener].arn

  priority = each.value.priority

  #############################################################
  # Action - Forward
  #############################################################

  dynamic "action" {

    for_each = each.value.action.type == "forward" ? [each.value.action] : []

    content {

      type = "forward"

      forward {

        #########################################################
        # Weighted Target Groups
        #########################################################

        dynamic "target_group" {

          for_each = try(action.value.target_groups, [])

          content {

            arn = aws_lb_target_group.this[target_group.value.name].arn

            weight = try(target_group.value.weight, 1)

          }

        }

        #########################################################
        # Stickiness
        #########################################################

        dynamic "stickiness" {

          for_each = try(action.value.stickiness, null) != null ? [action.value.stickiness] : []

          content {

            enabled  = stickiness.value.enabled
            duration = stickiness.value.duration

          }

        }

      }

    }

  }

  #############################################################
  # Action - Redirect
  #############################################################

  dynamic "action" {

    for_each = each.value.action.type == "redirect" ? [each.value.action] : []

    content {

      type = "redirect"

      redirect {

        protocol = try(action.value.protocol, "#{protocol}")
        port     = try(action.value.port, "#{port}")
        host     = try(action.value.host, "#{host}")
        path     = try(action.value.path, "/#{path}")
        query    = try(action.value.query, "#{query}")

        status_code = action.value.status_code

      }

    }

  }

  #############################################################
  # Action - Fixed Response
  #############################################################

  dynamic "action" {

    for_each = each.value.action.type == "fixed-response" ? [each.value.action] : []

    content {

      type = "fixed-response"

      fixed_response {

        content_type = action.value.content_type

        message_body = try(action.value.message_body, null)

        status_code = action.value.status_code

      }

    }

  }

  #############################################################
  # Host Header
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.host_headers, null) != null ? [each.value.conditions.host_headers] : []

    content {

      host_header {

        values = condition.value

      }

    }

  }

  #############################################################
  # Path Pattern
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.path_patterns, null) != null ? [each.value.conditions.path_patterns] : []

    content {

      path_pattern {

        values = condition.value

      }

    }

  }

  #############################################################
  # HTTP Request Method
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.http_methods, null) != null ? [each.value.conditions.http_methods] : []

    content {

      http_request_method {

        values = condition.value

      }

    }

  }

  #############################################################
  # Source IP
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.source_ips, null) != null ? [each.value.conditions.source_ips] : []

    content {

      source_ip {

        values = condition.value

      }

    }

  }

  #############################################################
  # HTTP Headers
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.http_headers, [])

    content {

      http_header {

        http_header_name = condition.value.name

        values = condition.value.values

      }

    }

  }

  #############################################################
  # Query Strings
  #############################################################

  dynamic "condition" {

    for_each = try(each.value.conditions.query_strings, [])

    content {

      query_string {

        key   = try(condition.value.key, null)
        value = condition.value.value

      }

    }

  }

}