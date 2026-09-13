output "cloudtrail_arn" {

  description = "CloudTrail ARN."

  value = module.cloudtrail.trail_arn

}

output "config_recorder_ID" {

  description = "AWS Config Recorder ID."

  value = module.aws_config.configuration_recorder_id

}

output "guardduty_detector_id" {

  description = "GuardDuty Detector."

  value = module.guardduty.detector_id

}

output "securityhub_arn" {

  description = "Security Hub ARN."

  value = module.securityhub.securityhub_arn

}

output "access_analyzer_arn" {

  description = "Access Analyzer ARN."

  value = module.access_analyzer.analyzer_arn

}

output "config_aggregator_arn" {

  description = "Config Aggregator ARN."

  value = module.config_aggregator.aggregator_arn

}