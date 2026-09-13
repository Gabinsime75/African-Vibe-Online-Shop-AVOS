# ============================================================
# ALB → Istio Ingress Security Group Rules
# ============================================================
#
# The AWS Load Balancer Controller registers Istio ingress pods
# directly in the ALB target group using targetType = "ip".
#
# Therefore, the EKS cluster security group must allow traffic
# from the ALB security group to:
#
#   8080  - Istio ingress HTTP traffic
#   15021 - Istio readiness / ALB health checks
# ============================================================

resource "aws_vpc_security_group_ingress_rule" "alb_to_istio_http" {
  security_group_id = module.eks.cluster_security_group_id

  referenced_security_group_id = var.alb_security_group_id

  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080

  description = "Allow ALB to Istio ingress HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "alb_to_istio_health_check" {
  security_group_id = module.eks.cluster_security_group_id

  referenced_security_group_id = var.alb_security_group_id

  ip_protocol = "tcp"
  from_port   = 15021
  to_port     = 15021

  description = "Allow ALB to Istio readiness health check"
}