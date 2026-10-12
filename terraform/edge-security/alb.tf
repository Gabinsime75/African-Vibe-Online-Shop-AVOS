locals {
  vpc_id = "vpc-03d5b15ed57a8815f"

  public_subnet_ids = [
    "subnet-0f29bd6e07dad9807",
    "subnet-0712b8b0e7d7a001e",
    "subnet-0f2c41b2eea093d59"
  ]

  gateway_node_security_group_id = "sg-0a3af7abfe79fc59a"

  gateway_ports = {
    traffic = 80
    health  = 15021
  }
}

resource "aws_security_group" "alb" {
  name        = "avos-dev-alb"
  description = "AVOS ALB access and gateway connectivity"
  vpc_id      = local.vpc_id

  tags = {
    Name = "avos-dev-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "validation_http" {
  for_each = var.validation_access_cidrs

  security_group_id = aws_security_group.alb.id
  description       = "Temporary administrator HTTP validation"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_gateway" {
  for_each = local.gateway_ports

  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = local.gateway_node_security_group_id
  description                  = "ALB to Istio gateway ${each.key}"
  ip_protocol                  = "tcp"
  from_port                    = each.value
  to_port                      = each.value
}

resource "aws_vpc_security_group_ingress_rule" "gateway_from_alb" {
  for_each = local.gateway_ports

  security_group_id            = local.gateway_node_security_group_id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Istio gateway ${each.key} from AVOS ALB"
  ip_protocol                  = "tcp"
  from_port                    = each.value
  to_port                      = each.value
}

resource "aws_lb" "avos" {
  name               = "avos-dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnet_ids

  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "istio" {
  name        = "avos-dev-istio"
  vpc_id      = local.vpc_id
  target_type = "ip"
  protocol    = "HTTP"
  port        = 80

  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "15021"
    path                = "/healthz/ready"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.avos.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio.arn
  }
}
