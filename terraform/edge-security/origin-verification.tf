# =============================================================================
# AVOS Phase 7 — Origin verification and administrator access
# =============================================================================

variable "origin_verification_secret" {
  description = "Secret header shared by CloudFront and the ALB."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[a-f0-9]{64}$", var.origin_verification_secret))
    error_message = "Provide a 64-character hexadecimal origin secret."
  }
}

resource "aws_lb_listener_rule" "administrator_https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio.arn
  }

  condition {
    source_ip {
      values = sort(tolist(var.validation_access_cidrs))
    }
  }
}

resource "aws_lb_listener_rule" "verified_cloudfront" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio.arn
  }

  condition {
    http_header {
      http_header_name = "X-AVOS-Origin-Key"
      values           = [var.origin_verification_secret]
    }
  }
}
