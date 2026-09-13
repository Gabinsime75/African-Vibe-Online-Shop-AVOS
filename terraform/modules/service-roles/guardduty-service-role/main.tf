module "guardduty_service_role" {

  source = "../../iam"

  role_name = var.role_name

  trusted_services = [
    "guardduty.amazonaws.com"
  ]

  policy_name        = "${var.role_name}-policy"
  policy_description = "AWS GuardDuty service permissions"

  policy_document = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "guardduty:*"
        ]

        Resource = "*"

      }

    ]

  })

  tags = var.tags

}