module "config_aggregator_role" {

  source = "../../iam"

  role_name = var.role_name

  trusted_services = [
    "config.amazonaws.com"
  ]

  policy_name        = "${var.role_name}-policy"
  policy_description = "AWS Config Aggregator permissions"

  policy_document = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "OrganizationsReadAccess"
        Effect = "Allow"

        Action = [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListAWSServiceAccessForOrganization",
          "organizations:ListDelegatedAdministrators",
          "organizations:ListDelegatedServicesForAccount"
        ]

        Resource = "*"
      },

      {
        Sid    = "ConfigAggregatorAccess"
        Effect = "Allow"

        Action = [
          "config:DescribeConfigurationAggregators",
          "config:DescribeConfigurationAggregatorSourcesStatus",
          "config:BatchGetAggregateResourceConfig",
          "config:SelectAggregateResourceConfig"
        ]

        Resource = "*"
      }

    ]

  })

  tags = var.tags

}