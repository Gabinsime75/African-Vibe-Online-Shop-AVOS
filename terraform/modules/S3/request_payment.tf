###############################################################
# S3 Request Payment Configuration
###############################################################

resource "aws_s3_bucket_request_payment_configuration" "this" {

  count = var.request_payer == "Requester" ? 1 : 0

  bucket = aws_s3_bucket.this.id

  payer = var.request_payer

}