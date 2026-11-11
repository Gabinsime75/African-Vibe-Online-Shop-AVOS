# =============================================================================
# AVOS Phase 7 — HTTPS origin for CloudFront
# =============================================================================

resource "aws_vpc_security_group_ingress_rule" "validation_https" {
  for_each = var.validation_access_cidrs

  security_group_id = aws_security_group.alb.id
  description       = "Administrator HTTPS validation"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.avos.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.origin.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}

resource "aws_route53_record" "origin" {
  zone_id = aws_route53_zone.avos.zone_id
  name    = "origin.avos-dev.cloudhusller.com"
  type    = "A"

  alias {
    name                   = aws_lb.avos.dns_name
    zone_id                = aws_lb.avos.zone_id
    evaluate_target_health = true
  }
}
