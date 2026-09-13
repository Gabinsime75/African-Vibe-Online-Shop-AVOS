output "detector_id" {
  description = "GuardDuty Detector ID."
  value       = aws_guardduty_detector.this.id
}

output "detector_arn" {
  description = "GuardDuty Detector ARN."
  value       = aws_guardduty_detector.this.arn
}

output "status" {
  description = "GuardDuty enabled status."
  value       = aws_guardduty_detector.this.enable
}