###############################################################
# S3 Object Lock Configuration
###############################################################

resource "aws_s3_bucket_object_lock_configuration" "this" {

  count = var.object_lock_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {

    default_retention {

      mode = var.object_lock_mode

      days = var.object_lock_days

    }

  }

}