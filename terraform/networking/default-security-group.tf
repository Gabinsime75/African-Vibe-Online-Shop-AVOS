# =============================================================================
# AVOS Network Foundation — Default Security Group
#
# Removes the permissive rules AWS creates automatically on the VPC default
# security group. AVOS workloads must use purpose-built security groups.
# =============================================================================

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = {
    Name    = "${local.name_prefix}-default-sg"
    Purpose = "IntentionallyRestricted"
  }
}