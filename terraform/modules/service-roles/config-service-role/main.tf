module "config_service_role" {

  source = "../../iam"

  role_name = var.role_name

  trusted_services = [
    "config.amazonaws.com"
  ]

  policy_name        = "${var.role_name}-policy"
  policy_description = "AWS Config service permissions"

  policy_document = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "config:*"
        ]

        Resource = "*"
      }

    ]

  })

  tags = var.tags

}