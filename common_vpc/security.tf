resource "aws_security_group" "fargate_task_sg" {
  name_prefix = "fargate-task-"
  description = "Security group for Fargate tasks"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.resource_prefix}.fargate-task-sg"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.resource_prefix}.vpc-endpoints"
  }
}

resource "aws_security_group_rule" "allow_fargate_to_endpoints" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate_task_sg.id
  source_security_group_id = aws_security_group.vpc_endpoints.id
  description              = "Allow outbound traffic to the VPC endpoints"
}

resource "aws_security_group_rule" "allow_endpoints_to_fargate" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate_task_sg.id
  source_security_group_id = aws_security_group.vpc_endpoints.id
  description              = "Allow inbound traffic from the VPC endpoints"
}

resource "aws_security_group_rule" "allow_outbound_to_s3_gateway" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.fargate_task_sg.id
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  description       = "Allow outbound traffic to the S3 gateway"
}
resource "aws_security_group_rule" "allow_fargate_to_rds" {
  type              = "egress"
  from_port         = 55432
  to_port           = 55432
  protocol          = "tcp"
  security_group_id = aws_security_group.fargate_task_sg.id
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  description       = "Allow outbound traffic to RDS database on port 55432"
}

resource "aws_security_group_rule" "allow_fargate_to_nfs" {
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.fargate_task_sg.id
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  description       = "Allow outbound traffic to NFS on port 2049"
}

resource "aws_security_group_rule" "allow_inbound_from_nfs_to_fargate" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.fargate_task_sg.id
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  description       = "Allow inbound traffic to NFS on port 2049"
}

resource "aws_security_group_rule" "allow_inbound_from_endpoints_to_fargate" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints.id
  source_security_group_id = aws_security_group.fargate_task_sg.id
  description              = "Allow inbound traffic from the VPC endpoints"
}

resource "aws_security_group_rule" "allow_outbound_from_endpoints_to_fargate" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints.id
  source_security_group_id = aws_security_group.fargate_task_sg.id
  description              = "Allow outbound traffic from the VPC endpoints"
}

