###############################################################
# Local Values
###############################################################

locals {

  #############################################################
  # Standardized Name
  #############################################################

  alb_name = substr(var.name, 0, 32)

  name_prefix = var.name

  #############################################################
  # Common Tags
  #############################################################

  common_tags = merge(

    var.tags,

    {
      Name      = local.alb_name
      Module    = "alb"
      ManagedBy = "Terraform"
    }

  )

  #############################################################
  # Access Logging
  #############################################################

  access_logs_enabled = try(var.access_logs.enabled, false)

  #############################################################
  # Listener Maps
  #############################################################

  http_listeners = {

    for key, listener in var.listeners :

    key => listener

    if upper(listener.protocol) == "HTTP"

  }

  https_listeners = {

    for key, listener in var.listeners :

    key => listener

    if upper(listener.protocol) == "HTTPS"

  }

  #############################################################
  # Target Group Lookup
  #############################################################

  target_group_keys = keys(var.target_groups)

  #############################################################
  # Listener Rule Lookup
  #############################################################

  listener_rule_keys = keys(var.listener_rules)

  #############################################################
  # Rule Action Types
  #############################################################

  forward_rules = {

    for key, rule in var.listener_rules :

    key => rule

    if lower(rule.action.type) == "forward"

  }

  redirect_rules = {

    for key, rule in var.listener_rules :

    key => rule

    if lower(rule.action.type) == "redirect"

  }

  fixed_response_rules = {

    for key, rule in var.listener_rules :

    key => rule

    if lower(rule.action.type) == "fixed-response"

  }


}