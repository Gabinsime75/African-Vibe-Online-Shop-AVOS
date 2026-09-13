## KMS Module Test-----------------------
# output "key_id" {
#   value = module.kms.key_id
# }

# output "key_arn" {
#   value = module.kms.key_arn
# }

# output "key_alias" {
#   value = module.kms.key_alias
# }

## S3 Module Test-------------------------
# output "bucket_id" {
#   value = module.s3.bucket_id
# }

# output "bucket_arn" {
#   value = module.s3.bucket_arn
# }

# output "bucket_name" {
#   value = module.s3.bucket_name
# }

# output "bucket_domain_name" {
#   value = module.s3.bucket_domain_name
# }

# output "regional_domain_name" {
#   value = module.s3.regional_domain_name
# }

## DynamoDB Module Test-----------------------------------
# output "table_name" {
#   value = module.dynamodb.table_name
# }

# output "table_arn" {
#   value = module.dynamodb.table_arn
# }

# output "table_id" {
#   value = module.dynamodb.table_id
# }

# output "hash_key" {
#   value = module.dynamodb.hash_key
# }

## IAM Module Test-----------------------------------
# output "role_name" {
#   value = module.iam.role_name
# }

# output "role_arn" {
#   value = module.iam.role_arn
# }

# output "policy_arn" {
#   value = module.iam.policy_arn
# }

# output "instance_profile_name" {
#   value = module.iam.instance_profile_name
# }

# output "permission_boundary_arn" {

#   value = module.iam.permission_boundary_arn

# }

## Organization Testing------------------------------------------


## Governance Testing------------------------------------------
output "cloudtrail_arn" {

  value = module.governance.cloudtrail_arn

}

output "config_recorder_name" {

  value = module.governance.config_recorder_name

}

output "guardduty_detector_id" {

  value = module.governance.guardduty_detector_id

}

output "securityhub_account_id" {

  value = module.governance.securityhub_account_id

}

output "access_analyzer_arn" {

  value = module.governance.access_analyzer_arn

}

output "detective_graph_arn" {

  value = module.governance.detective_graph_arn

}