###############################################################
# CloudTrail Logs Bucket
###############################################################

module "cloudtrail_bucket" {

  source = "../modules/s3"

  bucket_name = local.cloudtrail_bucket_name

  bucket_policy = data.aws_iam_policy_document.cloudtrail_bucket.json

  force_destroy = false

  enable_encryption = true

  sse_algorithm = "aws:kms"

  kms_key_arn = module.governance_kms.key_arn

  versioning_status = "Enabled"

  enable_public_access_block = true

  object_ownership = "BucketOwnerEnforced"

  tags = local.common_tags

}

###############################################################
# AWS Config Bucket
###############################################################

module "config_bucket" {

  source = "../modules/s3"

  bucket_name = local.config_bucket_name

  bucket_policy = data.aws_iam_policy_document.config_bucket.json

  force_destroy = false

  enable_encryption = true

  sse_algorithm = "aws:kms"

  kms_key_arn = module.governance_kms.key_arn

  versioning_status = "Enabled"

  enable_public_access_block = true

  object_ownership = "BucketOwnerEnforced"

  tags = local.common_tags

}