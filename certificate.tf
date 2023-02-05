resource "aws_acm_certificate" "this" {
  count    = var.config.acm_certificate_arn == null ? 1 : 0
  provider = aws.use1

  domain_name               = var.config.domain_name
  subject_alternative_names = var.config.domain_alias
  validation_method         = "DNS"
  tags                      = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  certificate = var.config.acm_certificate_arn != null ? var.config.acm_certificate_arn : aws_acm_certificate.this[0].status == "ISSUED" ? aws_acm_certificate.this[0].arn : null
}
