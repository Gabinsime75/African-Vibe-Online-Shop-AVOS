output "aggregator_name" {
  description = "AWS Config Aggregator name."
  value       = aws_config_configuration_aggregator.this.name
}

output "aggregator_arn" {
  description = "AWS Config Aggregator ARN."
  value       = aws_config_configuration_aggregator.this.arn
}

output "aggregator_id" {
  description = "AWS Config Aggregator ID."
  value       = aws_config_configuration_aggregator.this.id
}