# =============================================================================
# AVOS Terraform Bootstrap — AWS Data Sources
# Before creating the S3 bucket, we need Terraform to discover the authenticated AWS account ID dynamically.
# Reads metadata about the authenticated AWS account without creating or
# modifying infrastructure.
# =============================================================================

data "aws_caller_identity" "current" {}

# data "aws_partition" "current" {}