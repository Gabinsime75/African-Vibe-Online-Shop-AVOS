variable "aws_region" {
  description = "AWS Region containing the AVOS development cluster."
  type        = string
  default     = "us-east-2"
}

variable "aws_account_id" {
  description = "AWS account authorized for this Terraform root."
  type        = string
  default     = "396913735153"
}

variable "cluster_name" {
  description = "Existing AVOS EKS cluster."
  type        = string
  default     = "avos-dev-eks"
}
