###############################################################
# VPC
###############################################################

module "vpc" {

  source = "../modules/vpc"

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  #   availability_zones = var.availability_zones

  public_subnet_cidrs = var.public_subnet_cidrs

  private_app_subnet_cidrs = var.private_app_subnet_cidrs

  private_db_subnet_cidrs = var.private_db_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway

  single_nat_gateway = var.single_nat_gateway

  #   enable_vpc_flow_logs = var.enable_vpc_flow_logs

  tags = local.common_tags

}

###############################################################
# Security Groups
###############################################################

module "security_groups" {

  source = "../modules/security-groups"

  vpc_id = module.vpc.vpc_id

  security_groups = {

    alb = {

      name        = "${local.name_prefix}-alb-sg"
      description = "Security group for the public Application Load Balancer."

      ingress_rules = concat(

        var.enable_http_ingress ? [
          {
            description = "Allow HTTP inbound traffic."
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"

            cidr_blocks = var.alb_ingress_cidrs
          }
        ] : [],

        var.enable_https_ingress ? [
          {
            description = "Allow HTTPS inbound traffic."
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"

            cidr_blocks = var.alb_ingress_cidrs
          }
        ] : []

      )

      egress_rules = [
        {
          description = "Allow all outbound traffic."
          from_port   = 0
          to_port     = 0
          protocol    = "-1"

          cidr_ipv4 = "0.0.0.0/0"
        }
      ]

      tags = {
        Name = "${local.name_prefix}-alb-sg"
      }

    }

  }

  tags = local.common_tags

}

###############################################################
# ACM Certificate
###############################################################

module "acm" {

  source = "../modules/acm"

  count = var.enable_https ? 1 : 0

  domain_name = var.domain_name

  subject_alternative_names = local.acm_subject_alternative_names

  validation_method = "DNS"

  create_route53_records = true

  hosted_zone_id = var.hosted_zone_id

  key_algorithm = var.acm_key_algorithm

  certificate_transparency_logging_preference = var.certificate_transparency_logging_preference

  tags = local.common_tags

}

###############################################################
# Application Load Balancer
###############################################################

module "alb" {

  source = "../modules/alb"

  name = local.alb_name

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.public_subnet_ids

  security_group_ids = [
    module.security_groups.security_group_ids["alb"]
  ]

  internal = var.alb_internal

  ip_address_type = var.alb_ip_address_type

  enable_deletion_protection = var.enable_alb_deletion_protection

  enable_cross_zone_load_balancing = var.enable_alb_cross_zone_load_balancing

  enable_http2 = var.enable_alb_http2

  idle_timeout = var.alb_idle_timeout

  drop_invalid_header_fields = var.alb_drop_invalid_header_fields

  desync_mitigation_mode = var.alb_desync_mitigation_mode

  access_logs = {
    enabled = var.enable_alb_access_logs
    bucket  = var.alb_access_logs_bucket
    prefix  = var.alb_access_logs_prefix
  }

  target_groups = local.alb_target_groups

  listeners = local.active_alb_listeners

  listener_rules = {}

  tags = local.common_tags

}

###############################################################
# Route53 DNS Records
###############################################################

module "route53" {

  source = "../modules/route53"

  create_hosted_zone = false

  hosted_zone_id = var.hosted_zone_id

  hosted_zone_name = var.domain_name

  records = local.route53_records

  tags = local.common_tags

}

