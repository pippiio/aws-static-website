resource "aws_acm_certificate" "this" {
  count    = local.config.acm_certificate_arn == null ? 1 : 0
  provider = aws.use1

  domain_name       = local.config.domain_name
  validation_method = "DNS"
  tags              = local.default_tags
}
