variable "enable_validation_branch" {
  description = "Temporarily trust the Phase 7 branch for authentication testing. Disable before granting publication permissions."
  type        = bool
  default     = false
}
