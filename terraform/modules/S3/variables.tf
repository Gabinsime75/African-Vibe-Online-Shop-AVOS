###############################################################
# General
###############################################################

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete a bucket that contains objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

###############################################################
# Ownership Controls
###############################################################

variable "object_ownership" {
  description = "Object ownership setting."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition = contains([
      "BucketOwnerEnforced",
      "BucketOwnerPreferred",
      "ObjectWriter"
    ], var.object_ownership)

    error_message = "Invalid object ownership setting."
  }
}

###############################################################
# Public Access Block
###############################################################

variable "enable_public_access_block" {
  description = "Enable S3 Public Access Block."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Block public ACLs."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies."
  type        = bool
  default     = true
}

###############################################################
# Server Side Encryption
###############################################################

variable "enable_encryption" {
  description = "Enable default server-side encryption."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "SSE algorithm."
  type        = string
  default     = "AES256"

  validation {
    condition = contains([
      "AES256",
      "aws:kms"
    ], var.sse_algorithm)

    error_message = "Supported values are AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "KMS Key ARN used when aws:kms encryption is enabled."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Keys."
  type        = bool
  default     = true
}

variable "enable_server_side_encryption" {
  description = "Enable server-side encryption configuration."
  type        = bool
  default     = true
}

###############################################################
# Versioning
###############################################################

variable "versioning_status" {
  description = "Bucket versioning status."
  type        = string
  default     = "Enabled"

  validation {
    condition = contains([
      "Enabled",
      "Suspended"
    ], var.versioning_status)

    error_message = "Versioning status must be Enabled or Suspended."
  }
}

###############################################################
# Lifecycle Configuration
###############################################################

variable "lifecycle_rules" {
  description = "Lifecycle rules."
  type = list(object({

    id     = string
    status = string

    filter = optional(object({
      prefix = optional(string)
    }))

    expiration = optional(object({
      days = optional(number)
    }))

    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])

    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])

    noncurrent_version_expiration = optional(object({
      days = number
    }))

    abort_incomplete_multipart_upload_days = optional(number)

  }))

  default = []
}

###############################################################
# Logging
###############################################################

variable "enable_access_logging" {
  description = "Enable server access logging."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "Destination bucket for access logs."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Access log prefix."
  type        = string
  default     = "logs/"
}

###############################################################
# Website Hosting
###############################################################

variable "enable_website" {
  description = "Enable static website hosting."
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Website index document."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Website error document."
  type        = string
  default     = "error.html"
}

###############################################################
# CORS
###############################################################

variable "cors_rules" {
  description = "CORS configuration."
  type = list(object({

    allowed_headers = optional(list(string), [])

    allowed_methods = list(string)

    allowed_origins = list(string)

    expose_headers = optional(list(string), [])

    max_age_seconds = optional(number)

  }))

  default = []
}

###############################################################
# Bucket Policy
###############################################################

variable "attach_bucket_policy" {
  description = "Attach a bucket policy."
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "Bucket policy JSON."
  type        = string
  default     = null
}

###############################################################
# ACL
###############################################################

variable "enable_acl" {
  description = "Create an ACL."
  type        = bool
  default     = false
}

variable "acl" {
  description = "Bucket ACL."
  type        = string
  default     = "private"
}

###############################################################
# Transfer Acceleration
###############################################################

variable "enable_transfer_acceleration" {
  description = "Enable Transfer Acceleration."
  type        = bool
  default     = false
}

###############################################################
# Requester Pays
###############################################################

variable "request_payer" {
  description = "Requester Pays configuration."
  type        = string
  default     = "BucketOwner"

  validation {
    condition = contains([
      "BucketOwner",
      "Requester"
    ], var.request_payer)

    error_message = "Must be BucketOwner or Requester."
  }
}

###############################################################
# Object Lock
###############################################################

variable "object_lock_enabled" {
  description = "Enable Object Lock."
  type        = bool
  default     = false
}

###############################################################
# Replication
###############################################################

variable "replication_configuration" {
  description = "Replication configuration."
  type = object({

    role = string

    rules = list(object({

      id = string

      priority = number

      status = string

      delete_marker_replication_status = optional(string)

      filter = object({

        prefix = optional(string)

      })

      destination = object({

        bucket = string

        account = optional(string)

        storage_class = optional(string)

        replica_kms_key_id = optional(string)

      })

    }))

  })

  default = null
}

###############################################################
# notifications
###############################################################

variable "lambda_notifications" {
  description = "Lambda notifications."
  type = list(object({

    lambda_function_arn = string

    events = list(string)

    filter_prefix = optional(string)

    filter_suffix = optional(string)

  }))

  default = []
}

variable "sns_notifications" {
  description = "SNS notifications."
  type = list(object({

    topic_arn = string

    events = list(string)

    filter_prefix = optional(string)

    filter_suffix = optional(string)

  }))

  default = []
}

variable "sqs_notifications" {
  description = "SQS notifications."
  type = list(object({

    queue_arn = string

    events = list(string)

    filter_prefix = optional(string)

    filter_suffix = optional(string)

  }))

  default = []
}

###############################################################
# Intelligent Tiering
###############################################################

variable "intelligent_tiering" {
  description = "Intelligent tiering configuration."
  type = object({

    name = string

    status = optional(string, "Enabled")

    tiering = list(object({

      access_tier = string

      days = number

    }))

  })

  default = null
}

###############################################################
# Inventory
###############################################################

variable "inventory_configuration" {
  description = "Inventory configuration."
  type = object({

    name = string

    frequency = string

    included_object_versions = optional(string, "Current")

    destination = object({

      bucket_arn = string

      format = optional(string, "CSV")

      prefix = optional(string)

    })

  })

  default = null
}

###############################################################
# Analytics
###############################################################

variable "analytics_configuration" {
  description = "Storage analytics configuration."
  type = object({

    name = string

    destination = object({

      bucket_arn = string

    })

  })

  default = null
}

###############################################################
# Metrics
###############################################################

variable "metrics_configuration" {
  description = "Bucket metrics configuration."
  type = object({

    name = string

  })

  default = null
}

variable "object_lock_mode" {

  description = "Object Lock retention mode."

  type = string

  default = "GOVERNANCE"

  validation {

    condition = contains([
      "GOVERNANCE",
      "COMPLIANCE"
    ], var.object_lock_mode)

    error_message = "Mode must be GOVERNANCE or COMPLIANCE."

  }

}

variable "object_lock_days" {

  description = "Default retention days."

  type = number

  default = 30

}

variable "logging_configuration" {

  description = "Server access logging configuration."

  type = object({

    bucket = string

    prefix = optional(string, "logs/")

  })

  default = null

}