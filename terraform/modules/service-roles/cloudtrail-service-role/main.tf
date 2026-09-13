module "cloudtrail_service_role" {

  source = "../../iam"

  role_name = var.role_name

  trusted_services = [
    "cloudtrail.amazonaws.com"
  ]

  policy_name        = "${var.role_name}-policy"
  policy_description = "AWS CloudTrail service permissions"

  policy_document = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"

      }

    ]

  })

  tags = var.tags

}