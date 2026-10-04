locals {
  karpenter_interruption_events = {
    spot_interruption = {
      description = "Routes EC2 Spot interruption warnings to Karpenter."
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }

    rebalance_recommendation = {
      description = "Routes EC2 rebalance recommendations to Karpenter."
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }

    instance_state_change = {
      description = "Routes EC2 instance state changes to Karpenter."
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }

    scheduled_change = {
      description = "Routes EC2 scheduled maintenance events to Karpenter."
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
        detail = {
          service = ["EC2"]
        }
      }
    }
  }
}

resource "aws_sqs_queue" "karpenter_interruption" {
  name                       = "${local.name_prefix}-karpenter-interruption"
  message_retention_seconds  = 300
  sqs_managed_sse_enabled    = true
  visibility_timeout_seconds = 30

  tags = {
    Name    = "${local.name_prefix}-karpenter-interruption"
    Purpose = "KarpenterInterruptionHandling"
  }
}

resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  for_each = local.karpenter_interruption_events

  name          = "${local.name_prefix}-karpenter-${replace(each.key, "_", "-")}"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = {
    Name    = "${local.name_prefix}-karpenter-${replace(each.key, "_", "-")}"
    Purpose = "KarpenterInterruptionHandling"
  }
}

resource "aws_cloudwatch_event_target" "karpenter_interruption" {
  for_each = local.karpenter_interruption_events

  rule      = aws_cloudwatch_event_rule.karpenter_interruption[each.key].name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

data "aws_iam_policy_document" "karpenter_interruption_queue" {
  statement {
    sid    = "AllowEventBridge"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.karpenter_interruption.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        for rule in aws_cloudwatch_event_rule.karpenter_interruption :
        rule.arn
      ]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.karpenter_interruption.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy    = data.aws_iam_policy_document.karpenter_interruption_queue.json
}