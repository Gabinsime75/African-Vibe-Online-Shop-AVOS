###############################################################
# S3 Intelligent Tiering
###############################################################

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {

  count = local.use_intelligent_tiering ? 1 : 0

  bucket = aws_s3_bucket.this.id

  name = var.intelligent_tiering.name

  status = lookup(
    var.intelligent_tiering,
    "status",
    "Enabled"
  )

  dynamic "tiering" {

    for_each = var.intelligent_tiering.tiering

    content {

      access_tier = tiering.value.access_tier

      days = tiering.value.days

    }

  }

}