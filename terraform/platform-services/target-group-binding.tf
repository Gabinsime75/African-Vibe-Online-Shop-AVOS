################################################################################
# Istio Ingress TargetGroupBinding
################################################################################

# module "istio_ingress_target_group_binding" {
#   source = "../modules/target-group-binding"

#   name      = "istio-ingress"
#   namespace = "istio-ingress"

#   service_name = "istio-ingress"
#   service_port = 80

#   target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:396913735153:targetgroup/cloudhusller-dev-istio-ingress/0c4b1f50af0b4233"
#   target_type      = "ip"

#   labels = {
#     "app.kubernetes.io/name"       = "istio-ingress"
#     "app.kubernetes.io/instance"   = "istio-ingress"
#     "app.kubernetes.io/component"  = "ingress-gateway"
#     "app.kubernetes.io/part-of"    = "cloudhustler-commerce-platform"
#     "app.kubernetes.io/managed-by" = "terraform"
#   }

#   depends_on = [
#     module.aws_load_balancer_controller,
#     module.istio_ingress_gateway
#   ]
# }

module "istio_ingress_target_group_binding" {
  source = "../modules/target-group-binding"

  name             = "istio-ingress"
  namespace        = "istio-ingress"
  service_name     = "istio-ingress"
  service_port     = 80
  target_type      = "ip"
  target_group_arn = var.istio_ingress_target_group_arn

  depends_on = [
    module.aws_load_balancer_controller,
    module.istio_ingress_gateway
  ]
}

