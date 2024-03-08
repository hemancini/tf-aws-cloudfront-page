module "records" {
  source   = "terraform-aws-modules/route53/aws//modules/records"
  version  = "~> 2.0"
  for_each = toset(var.subdomains)

  zone_id = data.aws_route53_zone.this.zone_id
  records = [
    {
      name = each.key
      type = "A"
      alias = {
        name    = module.cloudfront[each.key].cloudfront_distribution_domain_name
        zone_id = module.cloudfront[each.key].cloudfront_distribution_hosted_zone_id
      }
    },
  ]
}
