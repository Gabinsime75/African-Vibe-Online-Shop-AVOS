# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.6 - Security Headers
#
# Purpose:
# Creates the CloudFront response headers policy used to enforce a consistent
# browser security baseline at the edge.
#
# The policy is applied to both the default application behavior and static
# content behavior so responses receive the same baseline protections before
# they are returned to viewers.
# =============================================================================

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.project_name}-${var.environment}-security-headers"
  comment = "Security response headers for the CloudHustler Commerce Platform"

  security_headers_config {

    # -------------------------------------------------------------------------
    # HTTP Strict Transport Security
    #
    # Instructs browsers to use HTTPS for subsequent requests.
    # -------------------------------------------------------------------------

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = false
      override                   = true
    }

    # -------------------------------------------------------------------------
    # X-Content-Type-Options
    #
    # Prevents MIME-type sniffing.
    # -------------------------------------------------------------------------

    content_type_options {
      override = true
    }

    # -------------------------------------------------------------------------
    # X-Frame-Options
    #
    # Prevents the application from being embedded in another site's iframe.
    # -------------------------------------------------------------------------

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # -------------------------------------------------------------------------
    # Referrer-Policy
    #
    # Limits sensitive URL information sent to other sites.
    # -------------------------------------------------------------------------

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}