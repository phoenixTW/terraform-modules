terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_security_group" "bastion_ec2_sg" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security group created for ${local.name_prefix} bastion"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${local.name_prefix}-bastion-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_internet_access_over_http" {
  security_group_id = aws_security_group.bastion_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_internet_access_over_https" {
  security_group_id = aws_security_group.bastion_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_to_connect_to_all_rds" {
  security_group_id = aws_security_group.bastion_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 55432
  ip_protocol       = "tcp"
  to_port           = 55432
  description       = "Allow bastion to connect to all RDS"
}

resource "aws_instance" "bastion_ec2" {
  ami           = "ami-0ae8f15ae66fe8cda"
  instance_type = "t2.micro"
  user_data     = templatefile("${path.module}/tpl/restrict_root_access.sh.tpl", {})

  subnet_id              = var.bastion_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  associate_public_ip_address = false

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "${local.name_prefix}-bastion"
  }
}
