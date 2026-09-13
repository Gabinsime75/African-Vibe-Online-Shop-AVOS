output "analyzer_name" {
  description = "IAM Access Analyzer name."
  value       = aws_accessanalyzer_analyzer.this.analyzer_name
}

output "analyzer_arn" {
  description = "IAM Access Analyzer ARN."
  value       = aws_accessanalyzer_analyzer.this.arn
}

output "analyzer_id" {
  description = "IAM Access Analyzer ID."
  value       = aws_accessanalyzer_analyzer.this.id
}

output "type" {
  description = "Analyzer type."
  value       = aws_accessanalyzer_analyzer.this.type
}