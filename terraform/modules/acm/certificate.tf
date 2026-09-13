###############################################################
# ACM Certificate
###############################################################

resource "aws_acm_certificate" "this" {

  #############################################################
  # Certificate Identity
  #############################################################

  domain_name = var.domain_name

  subject_alternative_names = var.subject_alternative_names

  #############################################################
  # Validation
  #############################################################

  validation_method = upper(var.validation_method)

  #############################################################
  # Certificate Key Algorithm
  #############################################################

  key_algorithm = var.key_algorithm

  #############################################################
  # Certificate Options
  #############################################################

  options {

    certificate_transparency_logging_preference = upper(
      var.certificate_transparency_logging_preference
    )

  }

  #############################################################
  # Resource Tags
  #############################################################

  tags = local.common_tags

  #############################################################
  # Lifecycle
  #############################################################

  lifecycle {

    create_before_destroy = true

  }

}