output "configuration_recorder_name" {
  description = "AWS Config Recorder name."
  value       = aws_config_configuration_recorder.this.name
}

output "configuration_recorder_id" {
  description = "AWS Config Recorder ID."
  value       = aws_config_configuration_recorder.this.id
}

output "delivery_channel_name" {
  description = "AWS Config Delivery Channel."
  value       = aws_config_delivery_channel.this.name
}

output "delivery_channel_id" {
  description = "AWS Config Delivery Channel ID."
  value       = aws_config_delivery_channel.this.id
}