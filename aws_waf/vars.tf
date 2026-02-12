variable "acl_name" {
  type        = string
  description = "ACL name for WAF"
}

variable "acl_description" {
  type        = string
  description = "ACL description for WAF"
}

variable "acl_scope" {
  type        = string
  description = "acl scope REGIONAL or CLOUDFRONT"
  default     = "CLOUDFRONT"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.acl_scope)
    error_message = "Allowed values for acl_scope are CLOUDFRONT or REGIONAL."
  }
}

variable "resource_arns" {
  type        = list(string)
  description = "ELB id for association to waf"
  default     = []
}

variable "rate_limit" {
  type        = number
  description = "Rate limit for WAF"
  default     = 2000
}

variable "rate_limit_evaluation_window" {
  type        = number
  description = "Rate limit evaluation window for WAF"
  default     = 120
}
