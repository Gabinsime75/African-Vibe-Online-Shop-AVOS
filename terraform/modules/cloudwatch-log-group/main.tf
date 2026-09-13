resource "aws_cloudwatch_log_group" "this" {

  name = var.name

  retention_in_days = var.retention_in_days

  kms_key_id = var.kms_key_id

  log_group_class = var.log_group_class

  skip_destroy = var.skip_destroy

  tags = var.tags

}