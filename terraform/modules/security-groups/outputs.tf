###############################################################
# Security Group IDs
###############################################################

output "security_group_ids" {
  description = "Map of security group IDs."

  value = {
    for name, sg in aws_security_group.this :
    name => sg.id
  }
}

###############################################################
# Security Group ARNs
###############################################################

output "security_group_arns" {
  description = "Map of security group ARNs."

  value = {
    for name, sg in aws_security_group.this :
    name => sg.arn
  }
}

###############################################################
# Security Group Names
###############################################################

output "security_group_names" {
  description = "Map of security group names."

  value = {
    for name, sg in aws_security_group.this :
    name => sg.name
  }
}

###############################################################
# Security Groups
###############################################################

output "security_groups" {
  description = "Complete map of created security groups."

  value = aws_security_group.this
}