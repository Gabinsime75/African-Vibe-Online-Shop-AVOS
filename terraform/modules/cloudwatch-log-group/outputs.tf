output "log_group_name" {
  description = "CloudWatch Log Group name."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN."
  value       = aws_cloudwatch_log_group.this.arn
}

output "log_group_id" {
  description = "CloudWatch Log Group ID."
  value       = aws_cloudwatch_log_group.this.id
}