variable "path_pattern" {
  description = "The pattern (for example \"images/*.jpg\") that specifies which requests you want this cache behavior to apply to. Not required for the default cache behavior!"
  type        = string
  default     = null
}

variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]

  validation {
    condition = alltrue([
      for v in var.allowed_methods : contains(["GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH"], v)
    ])
    error_message = "The allowed_methods value must be a list of valid HTTP methods."
  }
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods."
  type        = list(string)
  default     = ["GET", "HEAD"]

  validation {
    condition = alltrue([
      for v in var.cached_methods : contains(["GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH"], v)
    ])
    error_message = "The cached_methods value must be a list of valid HTTP methods."
  }
}

variable "viewer_protocol_policy" {
  description = "Use this element to specify the protocol that users can use to access the files in the origin when a requests matches this "
  type        = string
  default     = "redirect-to-https"
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "The viewer_protocol_policy value must be one of \"allow-all\", \"https-only\", or \"redirect-to-https\"."
  }
}

variable "compress" {
  description = "Whether you want CloudFront to automatically compress content for web requests that include \"Accept-Encoding: gzip\" in the request header."
  type        = bool
  default     = false
}

variable "min_ttl" {
  description = "The minimum amount of time (in seconds) that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated."
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an \"Cache-Control max-age\" or \"Expires\" header."
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of \"Cache-Control max-age\", \"Cache-Control s-maxage\", and \"Expires\" headers."
  type        = number
  default     = 86400
}

variable "forward_query_strings" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = true
}

variable "query_string_cache_keys" {
  description = "When specified, along with a value of true for \"forward_query_strings\", all query strings are forwarded, however only the query string keys listed in this argument are cached. When omitted with a value of true for \"forward_query_strings\", all query string keys are cached."
  type        = list(string)
  default     = []
}

variable "forward_cookies" {
  description = "Whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior. You can specify \"all\", \"none\", or \"whitelist\". If \"whitelist\", you must also set the \"whitelisted_cookie_names\" variable."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["all", "none", "whitelist"], var.forward_cookies)
    error_message = "The forward_cookies value must be one of \"all\", \"none\", or \"whitelist\"."
  }
}

variable "whitelisted_cookie_names" {
  description = "If you have specified \"whitelist\" in the \"forward_cookies\" variable, the whitelisted cookies that you want CloudFront to forward to your origin."
  type        = list(string)
  default     = []
}

variable "lambda_function_associations" {
  description = "A list of lambda function associations for cache behaviors (max 4)"
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(var.lambda_function_associations) <= 4
    error_message = "A maximum of 4 values are allowed for lambda_function_associations."
  }
  validation {
    condition = alltrue([
      for v in var.lambda_function_associations : contains(["viewer-request", "origin-request", "viewer-response", "origin-response"], v.event_type)
    ])
    error_message = "The event_type value of a lambda_function_associations value must be one of \"viewer-request\", \"origin-request\", \"viewer-response\", or \"origin-response\"."
  }
}

variable "function_associations" {
  description = "A list of CloudFront function associations for cache behaviors (max 2)"
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []

  validation {
    condition     = length(var.function_associations) <= 2
    error_message = "A maximum of 2 values are allowed for function_associations."
  }
  validation {
    condition = alltrue([
      for v in var.function_associations : contains(["viewer-request", "viewer-response"], v.event_type)
    ])
    error_message = "The event_type value of a function_associations value must be one of \"viewer-request\" or \"viewer-response\"."
  }
}
