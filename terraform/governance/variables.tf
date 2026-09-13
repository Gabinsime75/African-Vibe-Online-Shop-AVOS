###############################################################
# General
###############################################################

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "cloudhustler-commerce-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

#############################################
# AWS
#############################################

# variable "aws_region" {

#   description = "AWS Region."

#   type = string

# }

#############################################
# CloudTrail
#############################################

variable "cloudtrail_name" {

  description = "CloudTrail name."

  type = string

}

variable "cloudtrail_bucket_name" {

  description = "CloudTrail S3 bucket."

  type = string

}

variable "cloudtrail_role_name" {

  description = "CloudTrail service role."

  type = string

}

#############################################
# AWS Config
#############################################

variable "config_bucket_name" {

  description = "AWS Config S3 bucket."

  type = string

}

variable "config_role_name" {

  description = "AWS Config service role."

  type = string

}

# #############################################
# # KMS
# #############################################

# variable "kms_key_arn" {

#   description = "KMS Key ARN."

#   type = string

# }

#############################################
# GuardDuty
#############################################

variable "guardduty_role_name" {

  description = "GuardDuty service role."

  type = string

}

#############################################
# Security Hub
#############################################

variable "securityhub_role_name" {

  description = "Security Hub service role."

  type = string

}

#############################################
# Access Analyzer
#############################################

variable "access_analyzer_name" {

  description = "IAM Access Analyzer name."

  type = string

}

#############################################
# Config Aggregator
#############################################

variable "config_aggregator_name" {

  description = "Config Aggregator name."

  type = string

}

#############################################
# Tags
#############################################

# variable "tags" {

#   description = "Common resource tags."

#   type = map(string)

# }

variable "enable_config_delivery_policy" {
  description = "Attach the AWS Config delivery bucket policy."
  type        = bool
  default     = false
}

