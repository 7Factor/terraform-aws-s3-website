# S3 Website

This is an opinionated module that deploys an S3 bucket and a corresponding CloudFront distribution. This is excellent
for deploying modern SPAs in your favorite flavor of framework. See the variables file for documentation on how to use
this.

## Prerequisites

First, you need a decent understanding of how to use Terraform.
[Hit the docs](https://www.terraform.io/intro/index.html) for that. Then, you should familiarize yourself with ECS
[concepts](https://aws.amazon.com/ecs/getting-started/), especially if you've never worked with a clustering solution
before. Once you're good, import this module and pass the appropriate variables. Then, plan your run and deploy.

## Example Usage

```hcl-terraform
module "default_cache_behavior" {
  source  = "7Factor/s3-website/aws//modules/cache_behavior"
  version = "~> 2"
  
  compress = true
}

module "root_path_cache_behavior" {
  source  = "7Factor/s3-website/aws//modules/cache_behavior"
  version = "~> 2"
  
  path_pattern = "/"
  min_ttl      = 0
  default_ttl  = 0
  max_ttl      = 0
}

module "terraform-s3-website" {
  source  = "7Factor/s3-website/aws"
  version = "~> 2"

  s3_origin_id          = "mywebsite.com"
  cert_arn              = "arn:aws:acm:us-east-1:751713827483:certificate/ed5145d0-ada4-4e0f-8184-436b73a2935c"
  primary_fqdn          = "mywebsite.com"
  origins               = ["mywebsite.com", "www.mywebsite.com"]
  web_error_doc         = "index.html"

  custom_error_responses = [
    {
      error_caching_min_ttl = 3000
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    },
  ]
  
  default_cache_behavior = module.default_cache_behavior
  ordered_cache_behaviors = [module.root_path_cache_behavior]
}
```

## Migrating from github.com/7factor/terraform-s3-website

This is the new home of the terraform-s3-website. It was copied here so that changes wouldn't break services relying on
the old repo. Going forward, you should endeavour to use this version of the module. More specifically, use the [module
from the Terraform registry](https://registry.terraform.io/modules/7Factor/s3-website/aws/latest). This way, you can
select a range of versions to use in your service which allows us to make potentially breaking changes to the module
without breaking your service.

### Migration instructions

You need to change the module source from the GitHub url to `7Factor/s3-website/aws`. This will pull the module from
the Terraform registry. You should also add a version to the module block. See the [example](#example-usage) above for
what this looks like together.

**Major version 1 is intended to maintain backwards compatibility with the old module source.** To use the new module
source and maintain compatibility, set your version to `"~> 1"`. This means you will receive any updates that are
backwards compatible with the old module.
