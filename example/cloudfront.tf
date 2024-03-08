module "cdn" {
  source = "../"
  #   version = "1.0.0"

  domain_name        = "hemancini.cl"
  subdomains         = ["app"]
  log_enabled        = false
}

output "cloudfront_distribution_id" {
  value       = module.cdn.cloudfront_distribution_id
  description = "The ID of the CloudFront distribution"
}

output "s3_bucket_id" {
  value       = module.cdn.s3_bucket_id
  description = "The ID of the S3 bucket"
}
