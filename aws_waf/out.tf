output "waf_web_acl_arn" {
  value       = aws_wafv2_web_acl.waf_acl.arn
  description = "WAF wen ACL arn"
}

output "waf_cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.waf_acl_cloudwatch_log_group.name
  description = "WAF cloudwatch log group name"
}
