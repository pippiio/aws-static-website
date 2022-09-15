resource "aws_acm_certificate" "this" {
  count    = local.config.acm_certificate_arn == null ? 1 : 0
  provider = aws.use1

  domain_name               = local.config.domain_name
  subject_alternative_names = local.config.domain_alias
  validation_method         = "DNS"
  tags                      = local.default_tags
}
