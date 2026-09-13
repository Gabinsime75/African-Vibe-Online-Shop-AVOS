###############################################################
# S3 Bucket
###############################################################

resource "aws_s3_bucket" "this" {

  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled


  tags = local.default_tags

  lifecycle {

    precondition {
      condition     = length(var.bucket_name) >= 3
      error_message = "Bucket names must contain at least 3 characters."
    }

    precondition {
      condition     = length(var.bucket_name) <= 63
      error_message = "Bucket names cannot exceed 63 characters."
    }

  }

}