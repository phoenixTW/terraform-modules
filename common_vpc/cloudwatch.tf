resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "${var.service_name}-${var.env}-vpc-flow-logs"
  retention_in_days = var.flow_log_retention_days
  tags = merge(var.tags, {
    Name = "${var.service_name}-${var.env}-vpc-flow-logs"
  })
}

