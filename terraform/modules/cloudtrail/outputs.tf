output "trail_name" {
  description = "CloudTrail name."
  value       = aws_cloudtrail.this.name
}

output "trail_arn" {
  description = "CloudTrail ARN."
  value       = aws_cloudtrail.this.arn
}

output "home_region" {
  description = "Home region of the trail."
  value       = aws_cloudtrail.this.home_region
}

output "id" {
  description = "CloudTrail ID."
  value       = aws_cloudtrail.this.id
}