###############################################################
# General
###############################################################

output "bucket_id" {

  description = "Bucket ID."

  value = aws_s3_bucket.this.id

}

output "bucket_arn" {

  description = "Bucket ARN."

  value = aws_s3_bucket.this.arn

}

output "bucket_name" {

  description = "Bucket name."

  value = aws_s3_bucket.this.bucket

}

output "bucket_domain_name" {

  description = "Bucket domain name."

  value = aws_s3_bucket.this.bucket_domain_name

}

output "bucket_regional_domain_name" {

  description = "Regional bucket domain."

  value = aws_s3_bucket.this.bucket_regional_domain_name

}

output "hosted_zone_id" {

  description = "Hosted Zone ID."

  value = aws_s3_bucket.this.hosted_zone_id

}

###############################################################
# Website
###############################################################

output "website_endpoint" {

  description = "Website endpoint."

  value = try(
    aws_s3_bucket_website_configuration.this[0].website_endpoint,
    null
  )

}

###############################################################
# Encryption
###############################################################

output "kms_key_arn" {

  description = "KMS key ARN."

  value = var.kms_key_arn

}

###############################################################
# Versioning
###############################################################

output "versioning_status" {

  description = "Versioning status."

  value = aws_s3_bucket_versioning.this.versioning_configuration[0].status

}