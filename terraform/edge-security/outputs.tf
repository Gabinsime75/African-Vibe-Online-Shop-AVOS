output "alb_arn" {
  value = aws_lb.avos.arn
}

output "alb_dns_name" {
  value = aws_lb.avos.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "istio_target_group_arn" {
  value = aws_lb_target_group.istio.arn
}
