output "cloudfront_distribution_id" {
  value       = { for subdomain in var.subdomains : "${subdomain}.${var.domain_name}" => module.cloudfront[subdomain].cloudfront_distribution_id }
  description = "The ID of the CloudFront distribution"
}

output "s3_bucket_id" {
  value       = { for subdomain in var.subdomains : "${subdomain}.${var.domain_name}" => module.site_bucket[subdomain].s3_bucket_id }
  description = "The ID of the S3 bucket"
}
