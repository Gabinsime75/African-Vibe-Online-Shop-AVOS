# =============================================================================
# AVOS Data Services — Private Cart Redis
# =============================================================================

terraform {
  required_version = ">= 1.11, < 2.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = ["396913735153"]

  default_tags {
    tags = {
      Project       = "AVOS"
      Environment   = "dev"
      ManagedBy     = "Terraform"
      TerraformRoot = "data-services"
    }
  }
}

resource "aws_kms_key" "cart" {
  description             = "AVOS cart cache and credentials"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "cart" {
  name          = "alias/avos-dev-cart"
  target_key_id = aws_kms_key.cart.key_id
}

resource "aws_security_group" "cart_redis" {
  name        = "avos-dev-cart-redis"
  description = "Private Redis access from AVOS application nodes"
  vpc_id      = "vpc-0230b5b4745d680b5"
}

resource "aws_vpc_security_group_ingress_rule" "cart_redis" {
  security_group_id            = aws_security_group.cart_redis.id
  referenced_security_group_id = "sg-0d9a4383586b1ecea"
  description                  = "TLS Redis from AVOS application nodes"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
}

resource "aws_elasticache_subnet_group" "cart" {
  name        = "avos-dev-cart"
  description = "AVOS private data subnets"

  subnet_ids = [
    "subnet-0d8fa546c968c022c",
    "subnet-06d8ddc7c3e491e42",
    "subnet-0fd6c666338a70c7b",
  ]
}

resource "random_password" "cart" {
  length  = 40
  special = false
}

resource "aws_elasticache_replication_group" "cart" {
  replication_group_id = "avos-dev-cart"
  description          = "AVOS persistent development carts"

  engine               = "redis"
  engine_version       = "7.1"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"
  port                 = 6379

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.cart.name
  security_group_ids = [aws_security_group.cart_redis.id]

  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.cart.arn

  transit_encryption_enabled = true
  transit_encryption_mode    = "required"
  auth_token                 = random_password.cart.result
  auth_token_update_strategy = "SET"

  snapshot_retention_limit   = 7
  snapshot_window            = "05:00-06:00"
  maintenance_window         = "sun:07:00-sun:08:00"
  auto_minor_version_upgrade = true
}

resource "aws_secretsmanager_secret" "cart" {
  name                    = "avos/dev/cart-redis"
  description             = "TLS Redis credentials for cartservice"
  kms_key_id              = aws_kms_key.cart.arn
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "cart" {
  secret_id = aws_secretsmanager_secret.cart.id

  secret_string = jsonencode({
    address  = "${aws_elasticache_replication_group.cart.primary_endpoint_address}:6379"
    password = random_password.cart.result
  })
}

# ESO already has read access to avos/dev/* secrets.
# Permit decryption only through Secrets Manager for this secret.
resource "aws_iam_role_policy" "cart_secret_decryption" {
  name = "avos-dev-cart-secret-decryption"
  role = "avos-dev-external-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt"]
      Resource = aws_kms_key.cart.arn
      Condition = {
        StringEquals = {
          "kms:ViaService"                  = "secretsmanager.us-east-2.amazonaws.com"
          "kms:EncryptionContext:SecretARN" = aws_secretsmanager_secret.cart.arn
        }
      }
    }]
  })
}

output "cart_redis_endpoint" {
  value = aws_elasticache_replication_group.cart.primary_endpoint_address
}

output "cart_redis_secret_arn" {
  value = aws_secretsmanager_secret.cart.arn
}
