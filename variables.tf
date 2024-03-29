variable "config" {
  type = object({
    domain_name             = string
    path                    = optional(string)
    domain_alias            = optional(set(string), [])
    index_document          = optional(string, "index.html")
    error_document          = optional(string, "error.html")
    error_document_code     = optional(set(string), [400, 405, 414, 416, 500, 501, 502, 503, 504])
    response_headers_policy = optional(string, "Managed-SecurityHeadersPolicy")
    force_ssl_in_transit    = optional(bool, false)
    kms_arn                 = optional(string)
    acm_certificate_arn     = optional(string)
    log_retention           = optional(number, 35)
    expiration_days         = optional(number, 0)
    origin_shield_region    = optional(string)
    language_redirect       = optional(map(string), {})
    disallow_robots         = optional(bool, false)

    additional_origins = optional(map(object({
      domain_name     = string
      path            = optional(string)
      shielded        = optional(bool, false)
      protocol_policy = optional(string, "https-only")
      http_port       = optional(number, 80)
      https_port      = optional(number, 443)
      headers         = optional(map(string), {})
    })), {})

    additional_behaviors = optional(map(object({
      origin                   = string
      origin_protocol_policy   = optional(string, "https-only")
      allowed_methods          = optional(set(string), ["GET", "HEAD", "OPTIONS"])
      cached_methods           = optional(set(string), ["GET", "HEAD"])
      cache_policy             = optional(string, "Managed-CachingDisabled")
      origin_request_policy    = optional(string, "Managed-AllViewer")
      response_headers_policy  = optional(string, "Managed-SecurityHeadersPolicy")
      viewer_request_function  = optional(string)
      viewer_response_function = optional(string)
    })), {})

    firewall = optional(object({
      block_by_default = optional(bool, false)

      aws_managed_rules = optional(map(object({
        rule_action_override = optional(map(string), {})
        })), {
        AWSManagedRulesAmazonIpReputationList = {},
        AWSManagedRulesCommonRuleSet          = {}
      })

      blocked_ip_cidrs  = optional(set(string), [])
      blocked_countries = optional(set(string), [])
      allowed_ip_cidrs  = optional(set(string), [])
      allowed_countries = optional(set(string), [])
      rule_groups       = optional(map(string), {})
      bot_control = optional(object({
        start_path       = optional(string, "/")
        inspection_level = optional(string, "COMMON")
      }))
    }), {})
  })

  ##### Firewall #####

  validation {
    error_message = "Invalid rule action type. Valid values includes [allow, block, captcha, count]."
    condition     = try(alltrue(flatten([for rule in values(var.config.firewall.aws_managed_rules) : [for action in values(rule.rule_action_override) : contains(["allow", "block", "captcha", "count"], action)] if rule.rule_action_override != null])), true)
  }
}
