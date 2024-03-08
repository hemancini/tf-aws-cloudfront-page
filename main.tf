module "cloudfront" {
  source   = "terraform-aws-modules/cloudfront/aws"
  version  = "3.3.2"
  for_each = toset(var.subdomains)

  aliases             = ["${each.key}.${var.domain_name}"]
  comment             = "${each.key}.${var.domain_name} CloudFront"
  enabled             = true
  staging             = false # If you want to create a staging distribution, set this to true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  # default_root_object = "index.html"

  # If you want to create a primary distribution with a continuous deployment policy, set this to the ID of the policy.
  # This argument should only be set on a production distribution.
  # ref. `aws_cloudfront_continuous_deployment_policy` resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_continuous_deployment_policy
  continuous_deployment_policy_id = null

  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  create_monitoring_subscription = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_site = "${each.key}.${var.domain_name} CloudFront can access"
  }

  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  logging_config = var.log_enabled ? {
    bucket = module.log_bucket[each.key].s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  } : {}

  origin = {
    s3_site = { # with origin access identity (legacy)
      domain_name = module.site_bucket[each.key].s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_site" # key in `origin_access_identities`
        # cloudfront_access_identity_path = "origin-access-identity/cloudfront/E5IGQAA1QO48Z" # external OAI resource
      }
    }

    s3_oac = { # with origin access control settings (recommended)
      domain_name           = module.site_bucket[each.key].s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac" # key in `origin_access_control`
      # origin_access_control_id = "E345SXM82MIOSU" # external OAС resource
    }
  }

  origin_group = {
    group_one = {
      failover_status_codes      = [403, 404, 500, 502]
      primary_member_origin_id   = "s3_site"
      secondary_member_origin_id = "s3_oac"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_site"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = false

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.rewrite_default_index_request.arn
      }
    }
    # This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

  }
  viewer_certificate = {
    acm_certificate_arn = module.acm[each.key].acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response = var.custom_error_response

  geo_restriction = var.geo_restriction
}

# CloudFront function to rewrite the request URL to append index.html
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example-function-add-index.html
resource "aws_cloudfront_function" "rewrite_default_index_request" {
  name    = "add-index-html-to-request-urls"
  runtime = "cloudfront-js-2.0"
  comment = "URL rewrite to append index.html to the URI"
  publish = true
  code    = file("${path.module}/cloudfront-functions/url-rewrite-index-page.js")
}
