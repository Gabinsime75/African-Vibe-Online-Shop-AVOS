resource "aws_s3_bucket_policy" "this" {

  count = local.use_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id

  policy = var.bucket_policy

}