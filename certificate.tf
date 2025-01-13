resource "aws_acm_certificate" "this" {
  for_each = { for idx, bucket in var.config.buckets : idx => bucket if bucket.acm_certificate_arn == null }

  provider = aws.use1

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.domain_alias
  validation_method         = "DNS"
  tags                      = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  certificate_arns = {
    for idx, bucket in var.config.buckets : idx => (
      bucket.acm_certificate_arn != null ? bucket.acm_certificate_arn :
      aws_acm_certificate.this[idx].arn
    )
  }
}
