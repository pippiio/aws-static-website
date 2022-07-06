locals {
  config = defaults(var.config, {
    index_document     = "index.html"
    error_document     = "index.html"
    cache_policy       = "CachingOptimized"
    disable_cloudfront = false
  })

  provision_kms = local.config.kms_arn == null ? 1 : 0
  kms_arn       = try(aws_kms_key.this[0].arn, local.config.kms_arn)
}
