###############################################################
# VPC Configuration
###############################################################

variable "vpc_id" {
  description = "ID of the VPC where the security groups will be created."
  type        = string
}

###############################################################
# Security Groups
###############################################################

variable "security_groups" {
  description = "Map of security groups to create."

  type = map(object({

    description = optional(string, "")

    ingress_rules = optional(list(object({

      description = optional(string, "")

      from_port = number
      to_port   = number
      protocol  = string

      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)

      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids  = optional(list(string), [])

      self = optional(bool, false)

      source_security_group = optional(string)

    })), [])

    egress_rules = optional(list(object({

      description = optional(string, "")

      from_port = number
      to_port   = number
      protocol  = string

      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)

      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids  = optional(list(string), [])

      self = optional(bool, false)

      source_security_group = optional(string)

    })), [])

  }))
}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Tags applied to all security groups."
  type        = map(string)
  default     = {}
}