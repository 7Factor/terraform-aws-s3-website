module "acm" {
  count = local.should_create_cert ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5"

  domain_name = var.host_management.route53.record_name
  zone_id     = data.aws_route53_zone.root_zone.zone_id

  wait_for_validation = false

  tags = {
    Name = var.host_management.route53.record_name
  }
}
