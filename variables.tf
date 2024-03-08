# Required variables
variable "primary_fqdn" {
  description = "This is what we will name the S3 bucket. This must be in the list of DNS names that the app will be served from otherwise this won't work correctly."
}

variable "origins" {
  type        = list(string)
  description = "This is a list of domain names that will be passed into the CORS rule for the S3 bucket and the aliases list for cloud front. "
}

variable "s3_origin_id" {
  description = "A unique name value to assign to the s3 origin in CF. Try not to change it much."
}

variable "cert_arn" {
  description = "The ARN for a cert that will be fronting this distro. Make sure it exists."
}

variable "route53" {
  description = "If the module should create a new cert for the distribution. Fill out the below information."
  default     = null
  type = object({
    record_name = string
    zone_name   = string
    create_cert = bool
  })
}

variable "create_cert" {
  description = "If the module should create a new cert for the distribution. Fill out the below information."
  default     = false
  type        = bool
}

# Optional variables
variable "routing_rules" {
  description = "A string containing a compatible policy document with routing rules to assign to the S3 bucket. Defaults to empty."
  default     = ""
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return when an end user requests the root URL."
  default     = "index.html"
}

variable "web_index_doc" {
  description = "The path to the file where your app will deploy it's entrypoint."
  default     = "index.html"
}

variable "web_error_doc" {
  description = "The path to any custom error files that S3 will serve if there's a problem."
  default     = "error.html"
}

variable "cors_max_age_seconds" {
  description = "Max age for a CORS call in seconds. Assigned to the cors rules for the S3 bucket."
  default     = 3000
}

variable "cors_expose_headers" {
  type        = list(string)
  description = "The list of headers to expose on the S3 bucket. Defaults to an empty list."
  default     = []
}

variable "custom_error_responses" {
  type        = list(any)
  description = "A list of custom error response blocks. You probably won't need this unless you have a complex deployment."
  default     = []
}

variable "restriction_type" {
  description = "The restriction type for the CF distro when restricting content. Defaults to none."
  default     = "none"
}

variable "restriction_locations" {
  type        = list(string)
  description = "The list of locations to apply to the restriction type. Note this is ignored if the restriction type is none."
  default     = []
}

variable "default_cache_behavior" {
  description = "The default cache behavior for this distribute. See the modules/cache_behavior submodule for a simple way to create this."
  type = object({
    allowed_methods          = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods           = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy   = optional(string, "redirect-to-https")
    compress                 = optional(bool, false)
    min_ttl                  = optional(number, 1)
    default_ttl              = optional(number, 3600)
    max_ttl                  = optional(number, 86400)
    forward_query_strings    = optional(bool, true)
    query_string_cache_keys  = optional(list(string), [])
    forward_cookies          = optional(string, "none")
    whitelisted_cookie_names = optional(list(string), [])
    forward_headers          = optional(list(string), [])
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
  })
  default = {}
}

variable "ordered_cache_behaviors" {
  description = "An ordered list of cache behaviors for this distribution. List from top to bottom in order or precedence. The topmost cache behavior will have precedence 0. See the modules/cache_behavior submodule for a simple way to create this."
  type = list(object({
    path_pattern             = string
    allowed_methods          = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods           = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy   = optional(string, "redirect-to-https")
    compress                 = optional(bool, false)
    min_ttl                  = optional(number, 1)
    default_ttl              = optional(number, 3600)
    max_ttl                  = optional(number, 86400)
    forward_query_strings    = optional(bool, true)
    query_string_cache_keys  = optional(list(string), [])
    forward_cookies          = optional(string, "none")
    whitelisted_cookie_names = optional(list(string), [])
    forward_headers          = optional(list(string), [])
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
  }))
  default = []
}

variable "bucket_object_ownership" {
  description = "See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls#object_ownership : BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced. Defaults to ObjectWriter."
  default     = "ObjectWriter"
}

variable "allow_destroy_s3" {
  description = "Allow the S3 bucket to be destroyed even when not empty. Defaults to false."
  type        = bool
  default     = false
}
