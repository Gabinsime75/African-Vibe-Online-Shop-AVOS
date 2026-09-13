variable "aws_region" {
  description = "AWS region used by the CI infrastructure."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "CloudHustler project name."
  type        = string
  default     = "cloudhusller-commerce-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common infrastructure tags."
  type        = map(string)
  default     = {}
}

variable "github_owner" {
  description = "GitHub organization or username that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI IAM role."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the CI IAM role."
  type        = string
  default     = "main"
}