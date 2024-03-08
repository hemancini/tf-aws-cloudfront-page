## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_site_bucket"></a> [site\_bucket](#module\_site\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_log_bucket"></a> [log\_bucket](#module\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | terraform-aws-modules/cloudfront/aws | 3.3.2 |
| <a name="module_records"></a> [records](#module\_records) | terraform-aws-modules/route53/aws//modules/records | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_function.rewrite_default_index_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for all resources. | `string` | `"us-east-1"` | no |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | A list of custom error response elements | <pre>list(object({<br>    error_code         = number<br>    response_code      = number<br>    response_page_path = string<br>  }))</pre> | <pre>[<br>  {<br>    "error_code": 404,<br>    "response_code": 200,<br>    "response_page_path": "/index.html"<br>  },<br>  {<br>    "error_code": 403,<br>    "response_code": 200,<br>    "response_page_path": "/index.html"<br>  }<br>]</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name for the CloudFront distribution | `string` | n/a | yes |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | A list of geo restriction elements | <pre>object({<br>    restriction_type = string<br>    locations        = list(string)<br>  })</pre> | <pre>{<br>  "locations": [<br>    "CL"<br>  ],<br>  "restriction_type": "whitelist"<br>}</pre> | no |
| <a name="input_log_enabled"></a> [log_enabled](#input\_log_enabled) | Enable logging for CloudFront | `bool` | `true` | no |
| <a name="input_subdomains"></a> [subdomains](#input\_subdomains) | The subdomain for the CloudFront distribution | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The ID of the CloudFront distribution |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The ID of the S3 bucket |

## Example

```hcl
module "cdn" {
  source = "../"
  #   version = "1.0.0"

  domain_name = "example.com"
  subdomains  = ["app"]
}

output "cloudfront_distribution_id" {
  value       = module.cdn.cloudfront_distribution_id
  description = "The ID of the CloudFront distribution"
}

output "s3_bucket_id" {
  value       = module.cdn.s3_bucket_id
  description = "The ID of the S3 bucket"
}
```
