resource "aws_kms_key" "ecr" {
  description             = "AVOS development container image encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  rotation_period_in_days = 365

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountIAMPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::396913735153:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "avos-dev-ecr"
  }
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/avos/dev/ecr"
  target_key_id = aws_kms_key.ecr.key_id
}
