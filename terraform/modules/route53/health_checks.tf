###############################################################
# Route53 Health Checks
###############################################################

resource "aws_route53_health_check" "this" {

  for_each = var.health_checks

  #############################################################
  # Endpoint Configuration
  #############################################################

  fqdn       = try(each.value.fqdn, null)
  ip_address = try(each.value.ip_address, null)

  port = try(each.value.port, null)

  type = each.value.type

  resource_path = try(each.value.resource_path, null)

  search_string = try(each.value.search_string, null)

  #############################################################
  # Health Check Behavior
  #############################################################

  failure_threshold = try(each.value.failure_threshold, 3)

  request_interval = try(each.value.request_interval, 30)

  measure_latency = try(each.value.measure_latency, false)

  invert_healthcheck = try(each.value.invert_healthcheck, false)

  disabled = try(each.value.disabled, false)

  enable_sni = try(each.value.enable_sni, true)

  #############################################################
  # Calculated Health Checks
  #############################################################

  child_healthchecks = try(each.value.child_healthchecks, null)

  child_health_threshold = try(each.value.child_health_threshold, null)

  #############################################################
  # CloudWatch Alarm Health Checks
  #############################################################

  cloudwatch_alarm_name = try(each.value.cloudwatch_alarm_name, null)

  cloudwatch_alarm_region = try(each.value.cloudwatch_alarm_region, null)

  insufficient_data_health_status = try(each.value.insufficient_data_health_status, null)

  #############################################################
  # Regions
  #############################################################

  regions = try(each.value.regions, null)

  #############################################################
  # Resource Tags
  #############################################################

  tags = merge(
    local.common_tags,
    try(each.value.tags, {}),
    {
      Name = each.key
    }
  )

}