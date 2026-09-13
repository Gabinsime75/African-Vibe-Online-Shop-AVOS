###############################################################
# Application Load Balancer
###############################################################

output "id" {
  description = "ID of the Application Load Balancer."
  value       = aws_lb.this.id
}

output "arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "ARN suffix of the Application Load Balancer."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  value       = aws_lb.this.zone_id
}

###############################################################
# Listeners
###############################################################

output "listener_arns" {
  description = "Map of listener ARNs."

  value = {
    for name, listener in aws_lb_listener.this :
    name => listener.arn
  }
}

###############################################################
# Target Groups
###############################################################

output "target_group_ids" {
  description = "Map of target group IDs."

  value = {
    for name, tg in aws_lb_target_group.this :
    name => tg.id
  }
}

output "target_group_arns" {
  description = "Map of target group ARNs."

  value = {
    for name, tg in aws_lb_target_group.this :
    name => tg.arn
  }
}

output "target_group_names" {
  description = "Map of target group names."

  value = {
    for name, tg in aws_lb_target_group.this :
    name => tg.name
  }
}

###############################################################
# Listener Rules
###############################################################

output "listener_rule_ids" {
  description = "Map of listener rule IDs."

  value = {
    for name, rule in aws_lb_listener_rule.this :
    name => rule.id
  }
}

output "listener_rule_arns" {
  description = "Map of listener rule ARNs."

  value = {
    for name, rule in aws_lb_listener_rule.this :
    name => rule.arn
  }
}