output "role_name" {
  value = aws_iam_role.iam_role.name
}

output "role_arn" {
  value = aws_iam_role.iam_role.arn
}

output "role_id" {
  value = aws_iam_role.iam_role.id
}

output "policy_arn" {
  value = length(aws_iam_policy.iam_policy) > 0 ? aws_iam_policy.iam_policy[0].arn : null
}

output "instance_profile_name" {
  value = length(aws_iam_instance_profile.instance_profile) > 0 ? aws_iam_instance_profile.instance_profile[0].name : null
}

output "permission_boundary_arn" {
  value = length(aws_iam_policy.permission_boundary) > 0 ? aws_iam_policy.permission_boundary[0].arn : null
}