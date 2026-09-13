###############################################################
# S3 Server Access Logging
###############################################################

resource "aws_s3_bucket_logging" "this" {

  count = local.use_logging ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_configuration.bucket

  target_prefix = var.logging_configuration.prefix

}