# =============================================================================
# CloudHustler Commerce Platform
# Amazon ECR Module Variables
# =============================================================================

variable "repository_name" {
  description = "Name of the private Amazon ECR repository."
  type        = string
}

variable "tags" {
  description = "Common tags applied to the ECR repository."
  type        = map(string)
  default     = {}
}