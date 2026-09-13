###############################################################
# Hosted Zone Configuration
###############################################################

variable "create_hosted_zone" {
  description = "Whether to create a new Route53 hosted zone."
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID. Used when create_hosted_zone is false."
  type        = string
  default     = null
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name."
  type        = string
}

variable "private_zone" {
  description = "Whether the hosted zone is private."
  type        = bool
  default     = false
}

variable "comment" {
  description = "Comment for the Route53 hosted zone."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to destroy all records in the hosted zone when deleting the zone."
  type        = bool
  default     = false
}

variable "vpcs" {
  description = "VPC associations for private hosted zones."

  type = list(object({
    vpc_id     = string
    vpc_region = optional(string)
  }))

  default = []
}

###############################################################
# DNS Records
###############################################################

variable "records" {
  description = "Route53 DNS records."

  type = map(object({

    name = string
    type = string

    ttl     = optional(number)
    records = optional(list(string))

    set_identifier = optional(string)

    health_check_id = optional(string)

    health_check_key = optional(string)

    allow_overwrite = optional(bool, true)

    ###########################################################
    # Alias Record
    ###########################################################

    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }))

    ###########################################################
    # Weighted Routing
    ###########################################################

    weighted_routing_policy = optional(object({
      weight = number
    }))

    ###########################################################
    # Failover Routing
    ###########################################################

    failover_routing_policy = optional(object({
      type = string
    }))

    ###########################################################
    # Latency Routing
    ###########################################################

    latency_routing_policy = optional(object({
      region = string
    }))

    ###########################################################
    # Geolocation Routing
    ###########################################################

    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))

    ###########################################################
    # Multivalue Answer Routing
    ###########################################################

    multivalue_answer_routing_policy = optional(bool)

  }))

  default = {}
}

###############################################################
# Health Checks
###############################################################

variable "health_checks" {
  description = "Route53 health checks."

  type = map(object({

    fqdn              = optional(string)
    ip_address        = optional(string)
    port              = optional(number)
    type              = string
    resource_path     = optional(string)
    failure_threshold = optional(number, 3)
    request_interval  = optional(number, 30)

    search_string = optional(string)

    measure_latency = optional(bool, false)

    invert_healthcheck = optional(bool, false)

    disabled = optional(bool, false)

    enable_sni = optional(bool, true)

    child_healthchecks = optional(list(string))

    child_health_threshold = optional(number)

    cloudwatch_alarm_name   = optional(string)
    cloudwatch_alarm_region = optional(string)

    insufficient_data_health_status = optional(string)

    regions = optional(list(string))

    tags = optional(map(string), {})

  }))

  default = {}
}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Tags applied to supported Route53 resources."
  type        = map(string)
  default     = {}
}