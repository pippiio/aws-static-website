variable "config" {
  description = ""
  type = object({
    domain_name             = string
    domain_alias            = optional(set(string), [])
    index_document          = optional(string, "index.html")
    error_document          = optional(string, "index.html")
    allowed_ip_cidrs        = optional(set(string), [])
    cache_policy            = optional(string, "CachingOptimized")
    origin_request_policy   = optional(string, "CORS-S3Origin")
    response_headers_policy = optional(string, "SecurityHeadersPolicy")
    origin_shield_region    = optional(string, "eu-central-1")
    acm_certificate_arn     = optional(string)
    disable_cloudfront      = optional(bool, false)
    kms_arn                 = optional(string)
    log_retention           = optional(number, 35)
  })
}
