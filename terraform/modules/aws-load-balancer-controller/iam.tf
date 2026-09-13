# This module uses the controller’s documented TargetGroupBinding-only IAM permission subset, so it can register 
# and deregister pod IPs in existing target groups without permissions to create a new ALB.

###############################################################
# AWS Load Balancer Controller IAM Policy
#
# This policy intentionally supports TargetGroupBinding only.
# The controller may register and deregister pod IPs in target
# groups that are managed externally by Terraform.
###############################################################

data "aws_partition" "current" {}

resource "aws_iam_policy" "this" {
  count = var.create_iam_policy ? 1 : 0

  name        = var.iam_policy_name
  description = "IAM permissions for AWS Load Balancer Controller TargetGroupBinding operations."
  path        = var.iam_path

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "TargetGroupBindingReadAccess"
        Effect = "Allow"

        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth"
        ]

        Resource = "*"
      },
      {
        Sid    = "TargetGroupBindingManagement"
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]

        Resource = var.target_group_arns
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = var.iam_policy_name
      Component = "aws-load-balancer-controller"
    }
  )
}