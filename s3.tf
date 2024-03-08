data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "site_bucket" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "~> 4.0"
  for_each = toset(var.subdomains)

  bucket        = replace("site-${each.key}-${var.domain_name}", ".", "-")
  force_destroy = true
}

module "log_bucket" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "~> 4.0"
  for_each = var.log_enabled ? toset(var.subdomains) : []

  bucket                   = replace("logs-${each.key}-${var.domain_name}", ".", "-")
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  force_destroy = true
}

data "aws_iam_policy_document" "s3_policy" {
  for_each = toset(var.subdomains)
  # Origin Access Identities
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.site_bucket[each.key].s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront[each.key].cloudfront_origin_access_identity_iam_arns
    }
  }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.site_bucket[each.key].s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront[each.key].cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = toset(var.subdomains)
  bucket   = module.site_bucket[each.key].s3_bucket_id
  policy   = data.aws_iam_policy_document.s3_policy[each.key].json
}
