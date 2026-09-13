###############################################################
# Config Bucket Policy
###############################################################

data "aws_iam_policy_document" "config_bucket_policy" {

  statement {

    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      module.config_bucket.bucket_arn
    ]
  }

  statement {

    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${module.config_bucket.bucket_arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}



###############################################################
# AWS Config
###############################################################

module "aws_config" {

  source = "../modules/aws-config"

  configuration_recorder_name = local.config_recorder_name

  delivery_channel_name = local.config_delivery_channel_name

  s3_bucket_name = module.config_bucket.bucket_name

  iam_role_arn = module.config_service_role.role_arn

  tags = local.common_tags

}