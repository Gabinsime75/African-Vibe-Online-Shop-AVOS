
output "table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.dynamodb_table.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.dynamodb_table.arn
}


output "table_id" {
  description = "ID of the DynamoDB table."
  value       = aws_dynamodb_table.dynamodb_table.id
}


output "hash_key" {
  description = "Partition key of the DynamoDB table."
  value       = aws_dynamodb_table.dynamodb_table
}


# These outputs provide
# table_name – Useful for applications, Terraform backends, and other modules.
# table_arn – Commonly used in IAM policies and cross-module references.
# table_id – Terraform resource identifier.
# hash_key – Confirms the partition key configured for the table (e.g., LockID for Terraform state locking).