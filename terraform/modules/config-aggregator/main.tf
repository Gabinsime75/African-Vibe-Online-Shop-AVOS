#############################################
# AWS Config Aggregator
#############################################

resource "aws_config_configuration_aggregator" "this" {

  name = var.aggregator_name

  dynamic "organization_aggregation_source" {

    for_each = var.organization_aggregation ? [1] : []

    content {
      role_arn    = var.organization_role_arn
      all_regions = true

    }

  }

  dynamic "account_aggregation_source" {

    for_each = var.organization_aggregation ? [] : [1]

    content {

      account_ids = var.account_ids

      all_regions = length(var.aws_regions) == 0

      regions = length(var.aws_regions) > 0 ? var.aws_regions : null

    }

  }

  tags = var.tags

}