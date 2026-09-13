###############################################################
# S3 Bucket ACL
###############################################################

resource "aws_s3_bucket_acl" "this" {

  count = local.use_acl ? 1 : 0

  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]

  bucket = aws_s3_bucket.this.id

  acl = var.acl

}