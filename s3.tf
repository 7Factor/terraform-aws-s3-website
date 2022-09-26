resource "aws_s3_bucket" "web" {
  bucket = var.primary_fqdn
}

resource "aws_s3_bucket_acl" "web_acl" {
  bucket = aws_s3_bucket.web.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "allow_public_acl" {
  bucket            = aws_s3_bucket.web.id
  block_public_acls = false
}

resource "aws_s3_bucket_website_configuration" "web_site_configuration" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = var.web_index_doc
  }

  error_document {
    key = var.web_error_doc
  }

  routing_rules = var.routing_rules
}

resource "aws_s3_bucket_cors_configuration" "web_cors_configuration" {
  bucket = aws_s3_bucket.web.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }
}

resource "aws_s3_bucket_policy" "web_policy" {
  bucket = aws_s3_bucket.web.id
  policy = data.aws_iam_policy_document.web_policy_document.json
}

data "aws_iam_policy_document" "web_policy_document" {
  version = "2012-10-17"

  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_id.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.primary_fqdn}/*"
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_id.iam_arn]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.primary_fqdn}"
    ]
  }
}
