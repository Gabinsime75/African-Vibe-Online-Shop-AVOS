###############################################################
# S3 Lifecycle Configuration
###############################################################

resource "aws_s3_bucket_lifecycle_configuration" "this" {

  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {

    for_each = var.lifecycle_rules

    content {

      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {

        for_each = lookup(rule.value, "filter", null) != null ? [rule.value.filter] : []

        content {

          prefix = lookup(filter.value, "prefix", null)

        }

      }

      dynamic "expiration" {

        for_each = lookup(rule.value, "expiration", null) != null ? [rule.value.expiration] : []

        content {

          days = lookup(expiration.value, "days", null)

        }

      }

      dynamic "transition" {

        for_each = lookup(rule.value, "transitions", [])

        content {

          days          = transition.value.days
          storage_class = transition.value.storage_class

        }

      }

      dynamic "noncurrent_version_transition" {

        for_each = lookup(rule.value, "noncurrent_version_transitions", [])

        content {

          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class

        }

      }

      dynamic "noncurrent_version_expiration" {

        for_each = lookup(rule.value, "noncurrent_version_expiration", null) != null ? [rule.value.noncurrent_version_expiration] : []

        content {

          noncurrent_days = noncurrent_version_expiration.value.days

        }

      }

      abort_incomplete_multipart_upload {

        days_after_initiation = lookup(
          rule.value,
          "abort_incomplete_multipart_upload_days",
          7
        )

      }

    }

  }

}