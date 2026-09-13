###############################################################
# Application Load Balancer
###############################################################

resource "aws_lb" "this" {

  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"

  subnets         = var.subnet_ids
  security_groups = var.security_group_ids

  #############################################################
  # Networking
  #############################################################

  ip_address_type = var.ip_address_type

  #############################################################
  # Load Balancer Features
  #############################################################

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  idle_timeout = var.idle_timeout

  enable_http2 = var.enable_http2

  drop_invalid_header_fields = var.drop_invalid_header_fields

  desync_mitigation_mode = var.desync_mitigation_mode

  #   preserve_host_header                        = var.preserve_host_header
  #   enable_tls_version_and_cipher_suite_headers = var.enable_tls_version_and_cipher_suite_headers
  #   enable_xff_client_port                      = var.enable_xff_client_port
  #   xff_header_processing_mode                  = var.xff_header_processing_mode
  #   client_keep_alive                           = var.client_keep_alive

  #############################################################
  # Access Logs
  #############################################################

  dynamic "access_logs" {

    for_each = local.access_logs_enabled ? [1] : []

    content {

      bucket  = var.access_logs.bucket
      prefix  = try(var.access_logs.prefix, null)
      enabled = true

    }

  }

  #############################################################
  # Resource Tags
  #############################################################

  tags = local.common_tags

}