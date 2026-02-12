resource "aws_wafv2_web_acl" "waf_acl" {
  name        = var.acl_name
  description = var.acl_description
  scope       = var.acl_scope

  default_action {
    allow {}
  }

  rule {
    name     = "MantacaresRateLimitingWAFRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = var.rate_limit
        aggregate_key_type    = "IP"
        evaluation_window_sec = var.rate_limit_evaluation_window
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.acl_name}_waf_matric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.acl_name}_waf_matric"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl_logging_configuration" "waf_acl_logging_configuration" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_acl_cloudwatch_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.waf_acl.arn
}

resource "aws_cloudwatch_log_group" "waf_acl_cloudwatch_log_group" {
  name       = "aws-waf-logs-for-${var.acl_name}"
  kms_key_id = aws_kms_key.kms_key_waf_cloudwatch_log_group.arn
}

resource "aws_wafv2_web_acl_association" "waf_acl_association" {
  count        = length(var.resource_arns)
  resource_arn = var.resource_arns[count.index]
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}
