
# Generic IAM Role
resource "aws_iam_role" "iam_role" {
  name        = var.role_name
  description = var.role_description
  path        = var.path

  assume_role_policy = data.aws_iam_policy_document.trust_policy.json

  permissions_boundary = var.create_permission_boundary ? aws_iam_policy.permission_boundary[0].arn : null

  tags = var.tags

}