variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The domain name for the CloudFront distribution"
  type        = string
}

variable "subdomains" {
  description = "The subdomain for the CloudFront distribution"
  type        = list(string)
}

variable "log_enabled" {
  description = "Enable logging for CloudFront"
  type        = bool
  default     = true
}

variable "custom_error_response" {
  description = "A list of custom error response elements"
  type = list(object({
    error_code         = number
    response_code      = number
    response_page_path = string
  }))
  default = [{
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
    }, {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }]
}

variable "geo_restriction" {
  description = "A list of geo restriction elements"
  type = object({
    restriction_type = string
    locations        = list(string)
  })
  default = {
    restriction_type = "whitelist"
    locations        = ["CL", "PE", "AR"]
  }
}
