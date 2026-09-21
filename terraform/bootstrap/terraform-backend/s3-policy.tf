# =============================================================================
# AVOS Terraform Bootstrap — S3 State Bucket Policy
#
# Generates and attaches a bucket policy that denies all S3 operations sent
# over an insecure, non-TLS connection.
# =============================================================================

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]
}