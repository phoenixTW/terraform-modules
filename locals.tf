data "aws_region" "current" {}
locals {
  resource_prefix = "${var.service_name}.${var.env}.vpc"
}

