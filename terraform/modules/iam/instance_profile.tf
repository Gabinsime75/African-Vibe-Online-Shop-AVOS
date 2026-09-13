# IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  count = var.create_instance_profile ? 1 : 0
  name  = var.instance_profile_name != null ? var.instance_profile_name : var.role_name
  path  = var.path
  role  = aws_iam_role.iam_role.name

  tags = var.tags

}