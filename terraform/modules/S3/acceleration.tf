###############################################################
# S3 Transfer Acceleration
###############################################################

resource "aws_s3_bucket_accelerate_configuration" "this" {

  count = var.enable_transfer_acceleration ? 1 : 0

  bucket = aws_s3_bucket.this.id

  status = "Enabled"

}