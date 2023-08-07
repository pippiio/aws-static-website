# aws-static-website
A static-website based on S3 with CloudFront CDN

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (~> 4.0)

- <a name="provider_aws.use1"></a> [aws.use1](#provider\_aws.use1) (~> 4.0)

- <a name="provider_random"></a> [random](#provider\_random)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) (resource)
- [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) (resource)
- [aws_cloudfront_function.language_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) (resource)
- [aws_cloudfront_function.subdomain_to_path](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) (resource)
- [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) (resource)
- [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) (resource)
- [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) (resource)
- [aws_s3_bucket.access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) (resource)
- [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) (resource)
- [aws_s3_bucket_lifecycle_configuration.access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) (resource)
- [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) (resource)
- [aws_s3_bucket_ownership_controls.access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) (resource)
- [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) (resource)
- [aws_s3_bucket_public_access_block.access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) (resource)
- [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) (resource)
- [aws_wafv2_ip_set.allowed_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) (resource)
- [aws_wafv2_ip_set.blocked_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) (resource)
- [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) (resource)
- [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [random_pet.access_log](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
- [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
- [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_cloudfront_cache_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) (data source)
- [aws_cloudfront_cache_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) (data source)
- [aws_cloudfront_cache_policy.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) (data source)
- [aws_cloudfront_origin_request_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) (data source)
- [aws_cloudfront_origin_request_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) (data source)
- [aws_cloudfront_response_headers_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_response_headers_policy) (data source)
- [aws_cloudfront_response_headers_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_response_headers_policy) (data source)
- [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: n/a

Type:

```hcl
object({
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
        AWSManagedRulesCommonRuleSet = {}
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
```

## Example
```
module "website" {
  source = "github.com/pippiio/aws-static-website"

  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }

  name_prefix = replace("${terraform.workspace}-", "_", "-")
  config = {
    domain_name     = "example"
    error_document  = "404.html"
    log_retention   = 35
    expiration_days = 30
    disallow_robots = true
    language_redirect = {
      "da" = "/da/"
      "en" = "/en/"
      "*"  = "/en/"
    }
    firewall = {
      block_by_default = length(var.allowed_ip_addresses) > 0
      allowed_ip_cidrs = [for ip in var.allowed_ip_addresses : "${ip}/32"]
      bot_control = {
        start_path       = "/api/"
        inspection_level = "TARGETED"
      }
      aws_managed_rules = {
        AWSManagedRulesAmazonIpReputationList = {},
        AWSManagedRulesCommonRuleSet = {
          rule_action_override = {
            SizeRestrictions_BODY = "allow"
          }
        }
      }
    }
  }
}

```


## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags)

Description: A map of default tags, that will be applied to all resources applicable.

Type: `map(string)`

Default: `{}`

### <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix)

Description: A prefix that will be used on all named resources.

Type: `string`

Default: `"pippi-"`

## Outputs

The following outputs are exported:

### <a name="output_certificate_status"></a> [certificate\_status](#output\_certificate\_status)

Description: n/a

### <a name="output_certificate_validation_options"></a> [certificate\_validation\_options](#output\_certificate\_validation\_options)

Description: n/a

### <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name)

Description: The domain name of the CloudFront distribution.

### <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id)

Description: The id of the CloudFront distribution.

### <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn)

Description: The ARN of the KMS Key.

### <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket)

Description: The website S3 bucket.

### <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn)

Description: The website S3 bucket ARN.

### <a name="output_s3_website_domain"></a> [s3\_website\_domain](#output\_s3\_website\_domain)

Description: The website S3 bucket.

### <a name="output_secret"></a> [secret](#output\_secret)

Description: n/a
