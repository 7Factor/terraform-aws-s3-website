output "cf_distribution_id" {
  description = "The ID of the cloud front distro we created. Use this for DNS alias records and invalidation."
  value       = aws_cloudfront_distribution.web_distro.id
}

output "cf_domain" {
  description = "The domain name of the CF distribution."
  value       = aws_cloudfront_distribution.web_distro.domain_name
}

output "cf_hosted_zone_id" {
  description = "The hosted zone of the CF distro. Use this when pointing alias records to the distro."
  value       = aws_cloudfront_distribution.web_distro.hosted_zone_id
}

output "s3_bucket_name" {
  description = "The name of the bucket. Probably the same as the FQDN, but this so you're 100% sure to get the name."
  value       = aws_s3_bucket.web.bucket
}

output "fqdn" {
  description = "The fqdn of the route53 record created. Only defined if you requested the creation of a route53 record."
  value       = one(aws_route53_record.a_record[*].name)
}
