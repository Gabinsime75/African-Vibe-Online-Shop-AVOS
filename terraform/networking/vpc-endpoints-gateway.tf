# =============================================================================
# AVOS Network Foundation — Gateway VPC Endpoints
#
# Creates no-hourly-charge gateway endpoints for Amazon S3 and DynamoDB and
# associates them with all private application and private data route tables.
# =============================================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id

  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [
      for route_table in aws_route_table.private_application :
      route_table.id
    ],
    [
      for route_table in aws_route_table.private_data :
      route_table.id
    ]
  )

  tags = {
    Name         = "${local.name_prefix}-s3-endpoint"
    Service      = "S3"
    EndpointType = "Gateway"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = aws_vpc.this.id

  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [
      for route_table in aws_route_table.private_application :
      route_table.id
    ],
    [
      for route_table in aws_route_table.private_data :
      route_table.id
    ]
  )

  tags = {
    Name         = "${local.name_prefix}-dynamodb-endpoint"
    Service      = "DynamoDB"
    EndpointType = "Gateway"
  }
}