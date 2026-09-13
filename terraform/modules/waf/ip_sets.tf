resource "aws_wafv2_ip_set" "allow" {
  count = length(var.allow_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name}-allow-ip-set"
  description        = "Allowed IP addresses for ${var.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allow_ip_addresses

  tags = var.tags
}

resource "aws_wafv2_ip_set" "block" {
  count = length(var.block_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name}-block-ip-set"
  description        = "Blocked IP addresses for ${var.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.block_ip_addresses

  tags = var.tags
}