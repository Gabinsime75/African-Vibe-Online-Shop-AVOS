variable "validation_access_cidrs" {
  description = "Administrator IPv4 CIDRs allowed to test the initial HTTP listener."
  type        = set(string)

  validation {
    condition = (
      length(var.validation_access_cidrs) > 0 &&
      alltrue([
        for cidr in var.validation_access_cidrs :
        can(cidrnetmask(cidr)) && !endswith(cidr, "/0")
      ])
    )
    error_message = "Provide restricted IPv4 CIDRs; unrestricted /0 access is prohibited."
  }
}
