###############################################################
# Local Values
###############################################################

locals {

  #############################################################
  # Naming
  #############################################################

  name_prefix = "${var.project_name}-${var.environment}"

  vpc_name = "${local.name_prefix}-vpc"

  alb_name = "${local.name_prefix}-alb"

  #############################################################
  # Common Tags
  #############################################################

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Networking"
    }
  )

  #############################################################
  # ACM Domains
  #############################################################

  acm_subject_alternative_names = concat(
    var.acm_subject_alternative_names,
    var.create_www_record ? ["www.${var.domain_name}"] : []
  )

  #############################################################
  # ALB Listener Configuration
  #############################################################

  alb_listeners = {

    http = {
      port     = 80
      protocol = "HTTP"

      ssl_policy      = null
      certificate_arn = null
      alpn_policy     = null

      default_action = {
        type = var.enable_https ? "redirect" : "forward"

        #########################################################
        # Forward
        #########################################################

        target_groups = var.enable_https ? null : [
          {
            name   = "app"
            weight = 100
          }
        ]

        stickiness = null

        #########################################################
        # Redirect
        #########################################################

        protocol    = var.enable_https ? "HTTPS" : null
        port        = var.enable_https ? "443" : null
        host        = null
        path        = null
        query       = null
        status_code = var.enable_https ? "HTTP_301" : null

        #########################################################
        # Fixed Response
        #########################################################

        content_type = null
        message_body = null
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm[0].certificate_arn
      ssl_policy      = var.ssl_policy
      alpn_policy     = null

      default_action = {
        type = "forward"

        #########################################################
        # Forward
        #########################################################

        target_groups = [
          {
            name   = "istio_ingress"
            weight = 100
          }
        ]

        stickiness = var.enable_alb_stickiness ? {
          enabled  = true
          duration = var.alb_stickiness_duration
        } : null

        #########################################################
        # Redirect
        #########################################################

        protocol    = null
        port        = null
        host        = null
        path        = null
        query       = null
        status_code = null

        #########################################################
        # Fixed Response
        #########################################################

        content_type = null
        message_body = null
      }
    }

  }

  #############################################################
  # Active ALB Listeners
  #############################################################

  active_alb_listeners = merge(
    {
      http = local.alb_listeners.http
    },
    var.enable_https ? {
      https = local.alb_listeners.https
    } : {}
  )

  ###############################################################
  # ALB Target Groups
  ###############################################################

  alb_target_groups = {
    ###########################################################
    # Existing Application Target Group
    ###########################################################

    app = {
      name = "cloudhusller-commerce-platform-d"

      port        = var.app_target_group_port
      protocol    = var.app_target_group_protocol
      target_type = var.app_target_type

      protocol_version = null
      ip_address_type  = var.alb_ip_address_type

      deregistration_delay = var.app_deregistration_delay
      slow_start           = var.app_slow_start

      load_balancing_algorithm_type = var.app_load_balancing_algorithm_type

      health_check = {
        enabled             = var.app_health_check_enabled
        protocol            = var.app_health_check_protocol
        port                = var.app_health_check_port
        path                = var.app_health_check_path
        matcher             = var.app_health_check_matcher
        interval            = var.app_health_check_interval
        timeout             = var.app_health_check_timeout
        healthy_threshold   = var.app_healthy_threshold
        unhealthy_threshold = var.app_unhealthy_threshold
      }

      stickiness = {
        enabled         = var.enable_alb_stickiness
        type            = "lb_cookie"
        cookie_duration = var.alb_stickiness_duration
        cookie_name     = null
      }

      tags = {
        Workload = "Application"
      }
    }

    ###########################################################
    # Istio Ingress Gateway Target Group
    ###########################################################

    istio_ingress = {
      name = "cloudhusller-dev-istio-ingress"

      port        = var.istio_ingress_target_group_port
      protocol    = var.istio_ingress_target_group_protocol
      target_type = var.istio_ingress_target_type

      protocol_version = var.istio_ingress_protocol_version
      ip_address_type  = var.istio_ingress_ip_address_type

      deregistration_delay = var.istio_ingress_deregistration_delay
      slow_start           = var.istio_ingress_slow_start

      load_balancing_algorithm_type = var.istio_ingress_load_balancing_algorithm_type

      health_check = {
        enabled             = var.istio_ingress_health_check_enabled
        protocol            = var.istio_ingress_health_check_protocol
        port                = var.istio_ingress_health_check_port
        path                = var.istio_ingress_health_check_path
        matcher             = var.istio_ingress_health_check_matcher
        interval            = var.istio_ingress_health_check_interval
        timeout             = var.istio_ingress_health_check_timeout
        healthy_threshold   = var.istio_ingress_healthy_threshold
        unhealthy_threshold = var.istio_ingress_unhealthy_threshold
      }

      stickiness = {
        enabled         = var.enable_istio_ingress_stickiness
        type            = "lb_cookie"
        cookie_duration = var.istio_ingress_stickiness_duration
        cookie_name     = null
      }

      tags = {
        Workload                   = "IstioIngressGateway"
        ManagedByKubernetesTargets = "true"
      }
    }
  }
  #############################################################
  # Route53 Records
  #############################################################

  route53_records = merge(

    # ---------------------------------------------------------
    # Public Application Record
    #
    # During Phase 7.2.3 this record is disabled in networking
    # because cloudhusller.com will move to CloudFront and be
    # managed by the edge-security Terraform root.
    # ---------------------------------------------------------

    var.create_app_record ? {
      app = {
        name = var.app_domain_name
        type = "A"

        alias = {
          name                   = module.alb.dns_name
          zone_id                = module.alb.zone_id
          evaluate_target_health = true
        }
      }
    } : {},

    # ---------------------------------------------------------
    # Secure CloudFront Origin Record
    #
    # This record remains owned by the networking root because
    # it represents the origin-side relationship:
    #
    # origin.cloudhusller.com -> ALB
    # ---------------------------------------------------------

    {
      origin = {
        name = "origin.${var.domain_name}"
        type = "A"

        alias = {
          name                   = module.alb.dns_name
          zone_id                = module.alb.zone_id
          evaluate_target_health = true
        }
      }
    },

    # ---------------------------------------------------------
    # WWW Record
    #
    # This will also be disabled in networking because the
    # public www hostname will be managed by edge-security and
    # routed to CloudFront.
    # ---------------------------------------------------------

    var.create_www_record ? {
      www = {
        name = "www.${var.domain_name}"
        type = "A"

        alias = {
          name                   = module.alb.dns_name
          zone_id                = module.alb.zone_id
          evaluate_target_health = true
        }
      }
    } : {}
  )
}