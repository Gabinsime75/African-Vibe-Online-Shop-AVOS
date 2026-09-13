###############################################################
# S3 Inventory
###############################################################

resource "aws_s3_bucket_inventory" "this" {

  count = local.use_inventory ? 1 : 0

  bucket = aws_s3_bucket.this.id

  name = var.inventory_configuration.name

  included_object_versions = lookup(
    var.inventory_configuration,
    "included_object_versions",
    "Current"
  )

  schedule {

    frequency = var.inventory_configuration.frequency

  }

  destination {

    bucket {

      bucket_arn = var.inventory_configuration.destination.bucket_arn

      format = lookup(
        var.inventory_configuration.destination,
        "format",
        "CSV"
      )

      prefix = lookup(
        var.inventory_configuration.destination,
        "prefix",
        null
      )

    }

  }

}