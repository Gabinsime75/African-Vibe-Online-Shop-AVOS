###############################################################
# S3 Static Website Hosting
###############################################################

resource "aws_s3_bucket_website_configuration" "this" {

  count = local.use_website ? 1 : 0

  bucket = aws_s3_bucket.this.id

  index_document {

    suffix = var.index_document

  }

  error_document {

    key = var.error_document

  }

}