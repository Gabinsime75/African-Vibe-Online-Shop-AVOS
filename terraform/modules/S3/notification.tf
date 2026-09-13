###############################################################
# S3 Bucket Notifications
###############################################################

resource "aws_s3_bucket_notification" "this" {

  count = (
    length(var.lambda_notifications) +
    length(var.sns_notifications) +
    length(var.sqs_notifications)
  ) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  #############################################################
  # Lambda Notifications
  #############################################################

  dynamic "lambda_function" {

    for_each = var.lambda_notifications

    content {

      lambda_function_arn = lambda_function.value.lambda_function_arn

      events = lambda_function.value.events

      filter_prefix = lookup(lambda_function.value, "filter_prefix", null)

      filter_suffix = lookup(lambda_function.value, "filter_suffix", null)

    }

  }

  #############################################################
  # SNS Notifications
  #############################################################

  dynamic "topic" {

    for_each = var.sns_notifications

    content {

      topic_arn = topic.value.topic_arn

      events = topic.value.events

      filter_prefix = lookup(topic.value, "filter_prefix", null)

      filter_suffix = lookup(topic.value, "filter_suffix", null)

    }

  }

  #############################################################
  # SQS Notifications
  #############################################################

  dynamic "queue" {

    for_each = var.sqs_notifications

    content {

      queue_arn = queue.value.queue_arn

      events = queue.value.events

      filter_prefix = lookup(queue.value, "filter_prefix", null)

      filter_suffix = lookup(queue.value, "filter_suffix", null)

    }

  }

}