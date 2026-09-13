
# Table Name
variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

# Billing Mode
variable "billing_mode" {
  description = "Billing mode for the DynamoDB table."
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Hash Key
variable "hash_key" {
  description = "Partition key for the DynamoDB table."
  type        = string
}

# Point-in-Time Recovery
variable "point_in_time_recovery_enabled" {
  description = "Enable Point-in-Time Recovery (PITR)."
  type        = bool
  default     = true
}

# Deletion Protection
variable "deletion_protection_enabled" {
  description = "Enable deletion protection for the DynamoDB table."
  type        = bool
  default     = true
}

# Server-Side Encryption
variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption."
  type        = bool
  default     = true
}

# KMS Key ARN
variable "kms_key_arn" {
  description = "ARN of the customer-managed KMS key used for table encryption."
  type        = string
  default     = "arn:aws:kms:us-east-2:396913735153:key/414bda13-ddba-4616-a85d-289fce669e48"
}

# Table Class
variable "table_class" {
  description = "Storage class for the DynamoDB table."
  type        = string
  default     = "STANDARD"
}

# Resource Tags
variable "tags" {
  description = "Tags applied to the DynamoDB table."
  type        = map(string)
  default     = {}
}