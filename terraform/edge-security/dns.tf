# =============================================================================
# AVOS Edge — Public DNS Zone
# Restores the zone used by ExternalDNS and certificate DNS validation.
# =============================================================================

resource "aws_route53_zone" "avos" {
  name    = "cloudhusller.com"
  comment = "AVOS public DNS"

  tags = {
    Name = "cloudhusller.com"
  }
}

output "public_hosted_zone_id" {
  value = aws_route53_zone.avos.zone_id
}

output "public_hosted_zone_name_servers" {
  value = aws_route53_zone.avos.name_servers
}
