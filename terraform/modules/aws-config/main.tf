#############################################
# 1. Configuration Recorder
#############################################

resource "aws_config_configuration_recorder" "this" {

  name     = var.configuration_recorder_name
  role_arn = var.iam_role_arn

  recording_group {

    all_supported                 = var.recording_group_all_supported
    include_global_resource_types = var.include_global_resource_types

  }

}

#############################################
# 2. Delivery Channel
#############################################

resource "aws_config_delivery_channel" "this" {

  name = var.delivery_channel_name

  s3_bucket_name = var.s3_bucket_name
  sns_topic_arn  = var.sns_topic_arn

  depends_on = [

    aws_config_configuration_recorder.this

  ]

}

#############################################
# 3. Configuration Recorder Status
#############################################

resource "aws_config_configuration_recorder_status" "this" {

  name = aws_config_configuration_recorder.this.name

  is_enabled = true

  depends_on = [

    aws_config_delivery_channel.this

  ]

}