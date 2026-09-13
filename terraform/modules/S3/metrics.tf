###############################################################
# S3 Request Metrics
###############################################################

resource "aws_s3_bucket_metric" "this" {

  count = local.use_metrics ? 1 : 0

  bucket = aws_s3_bucket.this.id

  name = var.metrics_configuration.name

}