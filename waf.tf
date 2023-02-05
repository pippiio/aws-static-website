resource "aws_wafv2_ip_set" "allowed_cidrs" {
  provider = aws.use1

  name               = "allowed-ip-cidrs"
  description        = "Allowed IP cidrs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.config.firewall.allowed_ip_cidrs

  tags = local.default_tags
}

resource "aws_wafv2_ip_set" "blocked_cidrs" {
  provider = aws.use1

  name               = "blocked-ip-cidrs"
  description        = "Blocked IP cidrs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.config.firewall.blocked_ip_cidrs

  tags = local.default_tags
}

resource "aws_wafv2_web_acl" "this" {
  provider = aws.use1

  name        = "${local.name_prefix}cloudfront-waf"
  description = "Firewall_for_${local.name_prefix}website"
  scope       = "CLOUDFRONT"

  default_action {
    dynamic "allow" {
      for_each = var.config.firewall.block_by_default ? [] : [1]
      content {}
    }
    dynamic "block" {
      for_each = var.config.firewall.block_by_default ? [1] : []
      content {}
    }
  }

  # 0 Block invalid hostnames
  rule {
    name     = "block-invalid-hostname"
    priority = 0

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          byte_match_statement {
            positional_constraint = length(var.config.domain_alias) > 0 ? "RegexMatchStatement" : startswith(var.config.domain_name, "*") ? "ENDS_WITH" : "EXACTLY"
            search_string         = length(var.config.domain_alias) > 0 ? lower(replace(replace(format("^%s$", join("|", setunion([var.config.domain_name], var.config.domain_alias))), ".", "\\."), "*", "(xn--)?[a-z0-9][a-z0-9-_]*")) : replace(var.config.domain_name, "/^\\*/", "")

            field_to_match {
              single_header { name = "host" }
            }

            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-invalid-hostname"
      sampled_requests_enabled   = true
    }
  }

  # 1+ AWS Managed Rules
  dynamic "rule" {
    for_each = tolist(var.config.firewall.aws_managed_rules)

    content {
      name     = rule.value
      priority = 1 + rule.key

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = rule.value
      }
    }
  }

  # 10 Blocked IP CIDRs
  dynamic "rule" {
    for_each = length(var.config.firewall.blocked_ip_cidrs) > 0 ? [1] : []

    content {
      name     = "blocked-ip-cidrs"
      priority = 10

      action {
        block {}
      }

      statement {
        ip_set_reference_statement { arn = aws_wafv2_ip_set.blocked_cidrs.arn }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "blocked-ip-cidrs"
        sampled_requests_enabled   = true
      }
    }
  }

  # 11 Blocked countries
  dynamic "rule" {
    for_each = length(var.config.firewall.blocked_contries) > 0 ? [1] : []

    content {
      name     = "blocked-countries"
      priority = 11

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.config.firewall.blocked_contries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "blocked-countries"
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.config.disallow_robots ? [1] : []

    content {
      content      = <<-EOT
        User-agent: *
        Disallow: /
      EOT 
      content_type = "TEXT_PLAIN"
      key          = "robots-txt"
    }
  }

  # 12 Disallow robots
  dynamic "rule" {
    for_each = var.config.disallow_robots ? [1] : []

    content {
      name     = "robots-txt"
      priority = 12

      action {
        block {
          custom_response {
            custom_response_body_key = "robots-txt"
            response_code            = 200
          }
        }
      }

      statement {
        byte_match_statement {
          positional_constraint = "EXACTLY"
          search_string         = "/robots.txt"

          field_to_match {
            uri_path {}
          }

          text_transformation {
            priority = 0
            type     = "NONE"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "robots-txt"
      }
    }
  }

  # 21 Secret header
  rule {
    name     = "secret-header"
    priority = 21

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        positional_constraint = "EXACTLY"
        search_string         = random_password.this.result

        field_to_match {
          single_header { name = "x-${local.name_prefix}secret" }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "secret-header"
    }
  }

  # 22 Secret cookie
  rule {
    name     = "secret-cookie"
    priority = 22

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        positional_constraint = "EXACTLY"
        search_string         = random_password.this.result

        field_to_match {
          cookies {
            match_scope       = "KEY"
            oversize_handling = "NO_MATCH"
            match_pattern {
              included_cookies = ["x-${local.name_prefix}secret"]
            }
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "secret-cookie"
      sampled_requests_enabled   = true
    }
  }

  # 23 Allowed IP CIDRs
  dynamic "rule" {
    for_each = length(var.config.firewall.allowed_ip_cidrs) > 0 ? [1] : []

    content {
      name     = "allowed-ip-cidrs"
      priority = 23

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement { arn = aws_wafv2_ip_set.allowed_cidrs.arn }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "allowed-ip-cidrs"
        sampled_requests_enabled   = true
      }
    }
  }

  # 40+ Rule groups
  dynamic "rule" {
    for_each = var.config.firewall.rule_groups

    content {
      name     = rule.key
      priority = 40 + index(keys(var.config.firewall.rule_groups), rule.key)

      override_action {
        none {}
      }

      statement {
        rule_group_reference_statement {
          arn = rule.value
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = rule.key
      }
    }
  }

  # 90 Allowed countries
  dynamic "rule" {
    for_each = length(var.config.firewall.allowed_contries) > 0 ? [1] : []

    content {
      name     = "allowed-countries"
      priority = 90

      action {
        allow {}
      }

      statement {
        geo_match_statement {
          country_codes = var.config.firewall.allowed_contries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "allowed-countries"
      }
    }
  }

  tags = local.default_tags

  visibility_config {
    cloudwatch_metrics_enabled = false
    sampled_requests_enabled   = false
    metric_name                = "${local.name_prefix}cloudfront-waf"
  }
}
