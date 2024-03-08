data "aws_route53_zone" "root_zone" {
  name = var.host_management.route53.zone_name
}

resource "aws_route53_record" "a_record" {
  count   = var.host_management.route53 == null ? 1 : 0
  type    = "A"
  name    = var.host_management.route53.record_name
  zone_id = data.aws_route53_zone.root_zone.zone_id

  alias {
    name                   = aws_cloudfront_distribution.web_distro.domain_name
    zone_id                = aws_cloudfront_distribution.web_distro.hosted_zone_id
    evaluate_target_health = false
  }
}
