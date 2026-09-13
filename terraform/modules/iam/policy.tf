# Generic IAM Policy
resource "aws_iam_policy" "iam_policy" {

  count = var.policy_document != null ? 1 : 0

  name        = var.policy_name
  description = var.policy_description
  path        = var.path
  policy      = var.policy_document

  tags = var.tags

}

# Customer-Managed Policy Attachment
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {

  count = var.policy_document != null ? 1 : 0

  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy[0].arn

}

# AWS / Customer Managed Policy Attachments
resource "aws_iam_role_policy_attachment" "managed_policy_attachments" {

  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.iam_role.name
  policy_arn = each.value

}