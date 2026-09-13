
# Export the KMS Key ID. Used by AWS resources that require the key ID.
output "key_id" {

  description = "The unique identifier of the KMS key."
  value       = aws_kms_key.kms_key.id

}


# Export the KMS Key ARN. Used by downstream modules for encryption.
output "key_arn" {

  description = "The ARN of the KMS key."
  value       = aws_kms_key.kms_key.arn

}


# Export the KMS Key Alias. Provides a human-readable identifier for the key.
output "key_alias" {

  description = "The alias assigned to the KMS key."
  value       = aws_kms_alias.this.name

}


# Export the KMS Key Policy. Useful for auditing and troubleshooting.
output "key_policy" {

  description = "The KMS key policy in JSON format."
  value       = aws_kms_key_policy.this.policy

}


# Export the KMS Key state. Indicates whether the key is enabled.
output "is_enabled" {

  description = "Whether the KMS key is enabled."
  value       = aws_kms_key.kms_key.is_enabled

}


# Export the KMS Key rotation status. Confirms whether automatic rotation is enabled.
output "key_rotation_enabled" {

  description = "Whether automatic key rotation is enabled."
  value       = aws_kms_key.kms_key.enable_key_rotation

}