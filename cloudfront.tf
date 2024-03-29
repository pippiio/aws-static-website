resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "CloudFront identity for ${local.name_prefix}website"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
  comment             = "Cloudfront CDN for ${local.name_prefix}website"
  price_class         = "PriceClass_100"
  default_root_object = length(var.config.language_redirect) > 0 ? null : var.config.index_document
  aliases             = aws_acm_certificate.this[0].status != "ISSUED" ? [] : concat([var.config.domain_name], tolist(var.config.domain_alias))
  tags                = local.default_tags
  web_acl_id          = aws_wafv2_web_acl.this.arn

  origin {
    origin_id   = "${local.name_prefix}s3-website-bucket"
    domain_name = var.config.force_ssl_in_transit ? aws_s3_bucket.this.bucket_regional_domain_name : aws_s3_bucket_website_configuration.this.website_endpoint

    dynamic "s3_origin_config" {
      for_each = var.config.force_ssl_in_transit ? [1] : []

      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = !var.config.force_ssl_in_transit ? [1] : []

      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 10
      }
    }

    dynamic "custom_header" {
      for_each = !var.config.force_ssl_in_transit ? [1] : []

      content {
        name  = "Referer"
        value = random_password.this.result
      }
    }

    origin_shield {
      enabled              = true
      origin_shield_region = coalesce(var.config.origin_shield_region, local.region_name)
    }
  }

  dynamic "origin" {
    for_each = var.config.additional_origins

    content {
      origin_id   = origin.key
      domain_name = origin.value.domain_name
      origin_path = origin.value.path

      custom_origin_config {
        http_port              = origin.value.http_port
        https_port             = origin.value.https_port
        origin_protocol_policy = origin.value.protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_read_timeout    = 30
      }

      origin_shield {
        enabled              = origin.value.shielded
        origin_shield_region = coalesce(var.config.origin_shield_region, local.region_name)
      }

      dynamic "custom_header" {
        for_each = origin.value.headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id           = "${local.name_prefix}s3-website-bucket"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.default.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.default.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.default.id
    compress                   = true

    dynamic "function_association" {
      for_each = aws_cloudfront_function.subdomain_to_path

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value.arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = length(var.config.language_redirect) > 0 ? [1] : []

    content {
      path_pattern           = "/"
      target_origin_id       = "${local.name_prefix}s3-website-bucket"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      viewer_protocol_policy = "allow-all"
      cache_policy_id        = data.aws_cloudfront_cache_policy.disabled.id

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.language_redirect[0].arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.config.additional_behaviors

    content {
      path_pattern               = ordered_cache_behavior.key
      target_origin_id           = ordered_cache_behavior.value.origin
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      cache_policy_id            = data.aws_cloudfront_cache_policy.additional[ordered_cache_behavior.key].id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.additional[ordered_cache_behavior.key].id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.additional[ordered_cache_behavior.key].id
      compress                   = true
      viewer_protocol_policy     = "redirect-to-https"

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.viewer_request_function != null ? [1] : []

        content {
          event_type   = "viewer-request"
          function_arn = ordered_cache_behavior.value.viewer_request_function
        }
      }

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.viewer_response_function != null ? [1] : []

        content {
          event_type   = "viewer-response"
          function_arn = ordered_cache_behavior.value.viewer_response_function
        }
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.access_log.bucket_domain_name
    prefix          = "cloudfront/"
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.config.firewall.allowed_countries) > 0 ? "whitelist" : length(var.config.firewall.blocked_countries) > 0 ? "blacklist" : "none"
      locations        = length(var.config.firewall.allowed_countries) > 0 ? var.config.firewall.allowed_countries : var.config.firewall.blocked_countries
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.certificate == null

    acm_certificate_arn      = local.certificate
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  dynamic "custom_error_response" {
    for_each = var.config.error_document_code

    content {
      error_code            = custom_error_response.value
      response_code         = custom_error_response.value
      error_caching_min_ttl = 10
      response_page_path    = coalesce("/${var.config.error_document}", "/")
    }
  }

  depends_on = [
    aws_s3_bucket.this,
    aws_acm_certificate.this[0]
  ]
}

data "aws_cloudfront_cache_policy" "default" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "default" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_response_headers_policy" "default" {
  name = var.config.response_headers_policy
}

data "aws_cloudfront_cache_policy" "additional" {
  for_each = var.config.additional_behaviors

  name = each.value.cache_policy
}

data "aws_cloudfront_origin_request_policy" "additional" {
  for_each = var.config.additional_behaviors

  name = each.value.origin_request_policy
}

data "aws_cloudfront_response_headers_policy" "additional" {
  for_each = var.config.additional_behaviors

  name = each.value.response_headers_policy
}

resource "aws_cloudfront_function" "subdomain_to_path" {
  count = startswith(var.config.domain_name, "*.") ? 1 : 0

  name    = "subdomain-to-path"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect foo.example.com/ -> example.com/foo/ for wildcard domain"
  publish = true
  code    = file("${path.module}/src/subdomain-to-path.js")
}

resource "aws_cloudfront_function" "language_redirect" {
  count = length(var.config.language_redirect) > 0 ? 1 : 0

  name    = "viewer-language-redirect"
  runtime = "cloudfront-js-1.0"
  comment = "Redirects base on detected viewer language"
  publish = true
  code = templatefile("${path.module}/src/language-redirect.js", {
    known_language    = join(", ", [for language, location in var.config.language_redirect : "'${language}'" if language != "*"])
    default_location  = one([for language, location in var.config.language_redirect : location if language == "*"])
    language_location = { for language, location in var.config.language_redirect : language => location if language != "*" }
  })
}
