###############################################################
# AWS Account Information
###############################################################

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

###############################################################
# Local Values
###############################################################

locals {

  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}"

  default_tags = merge(
    {
      Terraform = "true"
      Module    = "s3"
    },
    var.tags
  )

  use_kms = (
    var.enable_encryption &&
    var.sse_algorithm == "aws:kms"
  )

  use_logging = (
    var.logging_configuration != null
  )

  # use_bucket_policy = (
  #   var.attach_bucket_policy &&
  #   var.bucket_policy != null
  # )

  use_acl = (
    var.enable_acl &&
    var.object_ownership != "BucketOwnerEnforced"
  )

  use_website = var.enable_website

  use_replication = (
    var.replication_configuration != null
  )

  use_inventory = (
    var.inventory_configuration != null
  )

  use_analytics = (
    var.analytics_configuration != null
  )

  use_metrics = (
    var.metrics_configuration != null
  )

  use_intelligent_tiering = (
    var.intelligent_tiering != null
  )

}