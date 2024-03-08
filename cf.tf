resource "aws_cloudfront_origin_access_identity" "access_id" {
  comment = "Created to facilitate CF access to ${var.primary_fqdn} and the corresponding bucket."
}

locals {
  should_create_cert = var.host_management.route53 != null && var.host_management.cert_arn == null
  cert_arn           = local.should_create_cert ? one(module.acm[*].acm_certificate_arn) : var.host_management.cert_arn
}

resource "aws_cloudfront_distribution" "web_distro" {
  enabled         = true
  is_ipv6_enabled = true

  default_root_object = var.default_root_object
  aliases             = var.origins

  origin {
    domain_name = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id   = var.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_id.cloudfront_access_identity_path
    }
  }

  viewer_certificate {
    acm_certificate_arn = local.cert_arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    target_origin_id       = var.s3_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    forwarded_values {
      query_string = var.default_cache_behavior.forward_query_strings
      headers      = var.default_cache_behavior.forward_headers

      cookies {
        forward           = var.default_cache_behavior.forward_cookies
        whitelisted_names = var.default_cache_behavior.whitelisted_cookie_names
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations

      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lambda_function_association.value.include_body
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }

    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    min_ttl     = var.default_cache_behavior.min_ttl
    default_ttl = var.default_cache_behavior.default_ttl
    max_ttl     = var.default_cache_behavior.max_ttl
    compress    = var.default_cache_behavior.compress
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern = ordered_cache_behavior.value.path_pattern

      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      target_origin_id       = var.s3_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      forwarded_values {
        query_string = ordered_cache_behavior.value.forward_query_strings
        headers      = ordered_cache_behavior.value.forward_headers

        cookies {
          forward           = ordered_cache_behavior.value.forward_cookies
          whitelisted_names = ordered_cache_behavior.value.whitelisted_cookie_names
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_associations

        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lambda_function_association.value.include_body
          lambda_arn   = lambda_function_association.value.lambda_arn
        }
      }

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl
      compress    = ordered_cache_behavior.value.compress
    }
  }

  dynamic "custom_error_response" {
    for_each = [for c in var.custom_error_responses : {
      error_caching_min_ttl = c.error_caching_min_ttl
      error_code            = c.error_code
      response_code         = c.response_code
      response_page_path    = c.response_page_path
    }]

    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_locations
    }
  }
}
