# IAM Permission Boundary Policy
resource "aws_iam_policy" "permission_boundary" {
  count       = var.create_permission_boundary ? 1 : 0
  name        = var.permission_boundary_name
  description = "Permission boundary for ${var.role_name}"
  path        = var.path

  policy = var.permission_boundary_policy

  tags = var.tags

}