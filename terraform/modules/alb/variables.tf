###############################################################
# General
###############################################################

variable "name" {
  description = "Name of the Application Load Balancer."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where target groups are created."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnets attached to the ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups attached to the ALB."
  type        = list(string)
}

variable "ip_address_type" {
  description = "IP address type."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be either ipv4 or dualstack."
  }
}

###############################################################
# Load Balancer Features
###############################################################

variable "enable_deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP headers."
  type        = bool
  default     = true
}

variable "desync_mitigation_mode" {
  description = "Desync mitigation mode."
  type        = string
  default     = "defensive"

  validation {
    condition = contains(
      ["monitor", "defensive", "strictest"],
      var.desync_mitigation_mode
    )
    error_message = "desync_mitigation_mode must be monitor, defensive or strictest."
  }
}

###############################################################
# Access Logs
###############################################################

variable "access_logs" {

  description = "Application Load Balancer access log configuration."

  type = object({

    enabled = optional(bool, false)

    bucket = optional(string)

    prefix = optional(string)

  })

  default = {}

  validation {
    condition = (
      !try(var.access_logs.enabled, false) ||
      try(var.access_logs.bucket, null) != null
    )

    error_message = "access_logs.bucket must be specified when access logging is enabled."
  }

}

###############################################################
# Target Groups
###############################################################

# variable "target_groups" {

#   description = "Application Load Balancer target groups."

#   type = map(object({

#     port        = number
#     protocol    = string
#     target_type = string

#     deregistration_delay          = optional(number, 300)
#     slow_start                    = optional(number, 0)
#     load_balancing_algorithm_type = optional(string, "round_robin")
#     stickiness = optional(object({
#       enabled = optional(bool, false)
#       type = optional(string, "lb_cookie")
#       cookie_duration = optional(number, 86400)
#       cookie_name = optional(string)
#     }))
#     health_check = optional(object({

#       enabled             = optional(bool, true)
#       protocol            = optional(string, "HTTP")
#       path                = optional(string, "/")
#       port                = optional(string, "traffic-port")
#       matcher             = optional(string, "200")
#       interval            = optional(number, 30)
#       timeout             = optional(number, 5)
#       healthy_threshold   = optional(number, 5)
#       unhealthy_threshold = optional(number, 2)

#     }))

#   }))

#   default = {}

# }


variable "target_groups" {
  description = "Map of Application Load Balancer target group configurations."

  type = map(object({
    name        = optional(string)
    port        = number
    protocol    = string
    target_type = string

    protocol_version = optional(string)
    ip_address_type  = optional(string)

    deregistration_delay = optional(number)
    slow_start           = optional(number)

    load_balancing_algorithm_type = optional(string)

    health_check = optional(object({
      enabled             = optional(bool)
      protocol            = optional(string)
      port                = optional(string)
      path                = optional(string)
      matcher             = optional(string)
      interval            = optional(number)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
    }))

    stickiness = optional(object({
      enabled         = optional(bool)
      type            = optional(string)
      cookie_duration = optional(number)
      cookie_name     = optional(string)
    }))

    lambda_multi_value_headers_enabled = optional(bool)
    tags                               = optional(map(string), {})
  }))
}
###############################################################
# Listeners
###############################################################

variable "listeners" {

  description = "Application Load Balancer listeners."

  type = map(object({

    port     = number
    protocol = string

    ssl_policy      = optional(string)
    certificate_arn = optional(string)
    alpn_policy     = optional(string)

    default_action = object({

      type = string

      ###########################################################
      # Forward
      ###########################################################

      target_groups = optional(list(object({

        name   = string
        weight = optional(number, 1)

      })))

      stickiness = optional(object({

        enabled  = bool
        duration = number

      }))

      ###########################################################
      # Redirect
      ###########################################################

      protocol    = optional(string)
      port        = optional(string)
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
      status_code = optional(string)

      ###########################################################
      # Fixed Response
      ###########################################################

      content_type = optional(string)
      message_body = optional(string)

    })

  }))

  default = {}

}

###############################################################
# Listener Rules
###############################################################

variable "listener_rules" {

  description = "Application Load Balancer listener rules."

  type = map(object({

    listener = string

    priority = number

    action = object({

      type = string

      ###########################################################
      # Forward
      ###########################################################

      target_groups = optional(list(object({

        name   = string
        weight = optional(number, 1)

      })))

      stickiness = optional(object({

        enabled  = bool
        duration = number

      }))

      ###########################################################
      # Redirect
      ###########################################################

      protocol    = optional(string)
      port        = optional(string)
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
      status_code = optional(string)

      ###########################################################
      # Fixed Response
      ###########################################################

      content_type = optional(string)
      message_body = optional(string)

    })

    conditions = object({

      host_headers = optional(list(string))

      path_patterns = optional(list(string))

      http_methods = optional(list(string))

      source_ips = optional(list(string))

      http_headers = optional(list(object({

        name   = string
        values = list(string)

      })))

      query_strings = optional(list(object({

        key   = optional(string)
        value = string

      })))

    })

  }))

  default = {}

}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}