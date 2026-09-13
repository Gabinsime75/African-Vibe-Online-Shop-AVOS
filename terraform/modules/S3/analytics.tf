###############################################################
# S3 Analytics Configuration
###############################################################

resource "aws_s3_bucket_analytics_configuration" "this" {

  count = local.use_analytics ? 1 : 0

  bucket = aws_s3_bucket.this.id

  name = var.analytics_configuration.name

  storage_class_analysis {

    data_export {

      destination {

        s3_bucket_destination {

          bucket_arn = var.analytics_configuration.destination.bucket_arn

          format = "CSV"

        }

      }

    }

  }

}