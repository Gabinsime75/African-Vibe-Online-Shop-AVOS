#############################################
# AWS Configuration
#############################################

variable "aws_region" {

  description = "AWS Region."

  type = string

  default = "us-east-2"

}

#############################################
# Tags
#############################################

variable "tags" {

  description = "Additional resource tags."

  type = map(string)

  default = {}

}

variable "config_service_role_name" {
  default = "CloudHustler-Config-Service-Role"
}

variable "cloudtrail_service_role_name" {
  default = "CloudHustler-CloudTrail-Service-Role"
}

variable "guardduty_service_role_name" {
  default = "CloudHustler-GuardDuty-Service-Role"
}

variable "securityhub_service_role_name" {
  default = "CloudHustler-SecurityHub-Service-Role"
}