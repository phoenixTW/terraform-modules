resource "aws_flow_log" "flow_logs" {
  count           = var.enable_flow_logs ? 1 : 0
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = "ALL"
  log_format      = "$${instance-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${pkt-srcaddr} $${pkt-dstaddr} $${bytes} $${start} $${end} $${action}"
  tags = merge(var.tags, {
    Name = "${var.service_name}-${var.env}-flow-logs"
  })
}

