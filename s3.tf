resource "random_pet" "this" {
  for_each = var.config.buckets

  keepers = {
    account = local.region_name
    region  = local.account_id
    name    = local.name_prefix
  }
}

resource "aws_s3_bucket" "this" {
  for_each = var.config.buckets

  bucket = "${local.name_prefix}static-website-${random_pet.this[each.key].id}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  index_document {
    suffix = var.config.index_document
  }

  error_document {
    key = var.config.error_document
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = {
    for bucket_key, bucket in aws_s3_bucket.this : bucket_key => bucket if var.config.expiration_days >= 0
  }

  bucket = each.value.id

  rule {
    id     = "expire"
    status = "Enabled"

    expiration {
      days = var.config.expiration_days
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "Allow SSL Requests Only"
    effect = "Deny"
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    actions = ["s3:PutObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "Deny Incorrect Encryption Header"
    effect = "Deny"
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    actions = ["s3:PutObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }

  statement {
    sid    = "Deny Unencrypted Object Uploads"
    effect = "Deny"
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    actions = ["s3:PutObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid = "Allow CloudFront Browsing"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement {
    sid = "Allow HTTP request w. secret referer header"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:Referer"
      values   = [random_password.this.result]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  policy = data.aws_iam_policy_document.this.json
}
