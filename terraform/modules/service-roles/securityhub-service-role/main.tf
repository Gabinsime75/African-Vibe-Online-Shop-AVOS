module "securityhub_service_role" {

  source = "../../iam"

  role_name = var.role_name

  trusted_services = [
    "securityhub.amazonaws.com"
  ]

  policy_name        = "${var.role_name}-policy"
  policy_description = "AWS Security Hub service permissions"

  policy_document = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "securityhub:*"
        ]

        Resource = "*"

      }

    ]

  })

  tags = var.tags

}