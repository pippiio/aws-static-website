resource "random_pet" "access_log" {
  keepers = {
    account = local.region_name
    region  = local.account_id
    name    = local.name_prefix
  }
}

resource "aws_s3_bucket" "access_log" {
  bucket = "${local.name_prefix}access-log-${random_pet.access_log.id}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_ownership_controls" "access_log" {
  bucket = aws_s3_bucket.access_log.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "access_log" {
  bucket = aws_s3_bucket.access_log.id

  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_log" {
  bucket = aws_s3_bucket.access_log.id

  rule {
    id     = "access-log-retention"
    status = "Enabled"

    filter {
      prefix = "cloudfront/"
    }

    expiration {
      days = var.config.log_retention
    }
  }
}
