# variable "aws_region" {

#   description = "AWS Region"

#   type = string

#   default = "us-east-2"

# }

## Organization Testing------------------------------------------
#############################################
# AWS Region
#############################################

# variable "aws_region" {

#   description = "AWS Region."

#   type = string

#   default = "us-east-2"

# }

## Governance Testing------------------------------------------
variable "aws_region" {

  description = "AWS Region"
  type        = string
  default     = "us-east-2"

}

variable "organization_id" {
  type = string
}

variable "cloudtrail_s3_bucket_name" {
  type = string
}

variable "cloudtrail_kms_key_arn" {
  type = string
}

variable "config_s3_bucket_name" {
  type = string
}

variable "config_service_role_arn" {
  type = string
}