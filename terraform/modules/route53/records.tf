###############################################################
# Route53 DNS Records
###############################################################

resource "aws_route53_record" "this" {

  for_each = var.records

  #############################################################
  # Hosted Zone
  #############################################################

  zone_id = local.hosted_zone_id

  #############################################################
  # Record Identity
  #############################################################

  name = each.value.name

  type = upper(each.value.type)

  #############################################################
  # Standard Records
  #############################################################

  ttl = try(each.value.alias, null) == null ? try(each.value.ttl, 300) : null

  records = try(each.value.alias, null) == null ? try(each.value.records, null) : null

  #############################################################
  # Routing Identity
  #############################################################

  set_identifier = try(each.value.set_identifier, null)

  health_check_id = try(
    each.value.health_check_id,
    try(aws_route53_health_check.this[each.value.health_check_key].id, null)
  )

  allow_overwrite = try(each.value.allow_overwrite, true)

  #############################################################
  # Alias Records
  #############################################################

  dynamic "alias" {

    for_each = try(each.value.alias, null) != null ? [each.value.alias] : []

    content {

      name = alias.value.name

      zone_id = alias.value.zone_id

      evaluate_target_health = try(
        alias.value.evaluate_target_health,
        true
      )

    }

  }

  #############################################################
  # Weighted Routing Policy
  #############################################################

  dynamic "weighted_routing_policy" {

    for_each = try(each.value.weighted_routing_policy, null) != null ? [each.value.weighted_routing_policy] : []

    content {

      weight = weighted_routing_policy.value.weight

    }

  }

  #############################################################
  # Failover Routing Policy
  #############################################################

  dynamic "failover_routing_policy" {

    for_each = try(each.value.failover_routing_policy, null) != null ? [each.value.failover_routing_policy] : []

    content {

      type = upper(failover_routing_policy.value.type)

    }

  }

  #############################################################
  # Latency Routing Policy
  #############################################################

  dynamic "latency_routing_policy" {

    for_each = try(each.value.latency_routing_policy, null) != null ? [each.value.latency_routing_policy] : []

    content {

      region = latency_routing_policy.value.region

    }

  }

  #############################################################
  # Geolocation Routing Policy
  #############################################################

  dynamic "geolocation_routing_policy" {

    for_each = try(each.value.geolocation_routing_policy, null) != null ? [each.value.geolocation_routing_policy] : []

    content {

      continent = try(geolocation_routing_policy.value.continent, null)

      country = try(geolocation_routing_policy.value.country, null)

      subdivision = try(
        geolocation_routing_policy.value.subdivision,
        null
      )

    }

  }

  #############################################################
  # Multivalue Answer Routing Policy
  #############################################################

  multivalue_answer_routing_policy = try(
    each.value.multivalue_answer_routing_policy,
    null
  )

}