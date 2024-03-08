data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source   = "terraform-aws-modules/acm/aws"
  version  = "~> 4.0"
  for_each = toset(var.subdomains)

  domain_name               = var.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${each.key}.${var.domain_name}"]
}
