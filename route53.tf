data "aws_route53_zone" "root_zone" {
  name = var.route53.zone_name
}

resource "aws_route53_record" "a_record" {
  count   = var.route53 ? 1 : 0
  type    = "A"
  name    = var.route53.record_name
  zone_id = data.aws_route53_zone.root_zone.zone_id

  alias {
    name                   = aws_cloudfront_distribution.web_distro.domain_name
    zone_id                = aws_cloudfront_distribution.web_distro.hosted_zone_id
    evaluate_target_health = false
  }
}
