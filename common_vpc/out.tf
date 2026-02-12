output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.public.*.cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_subnet_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "database_subnets_ids" {
  value       = aws_subnet.database.*.id
  description = "List of databases subnets ID"
}

output "aws_db_subnet_group_name" {
  value       = length(var.database_subnets) > 0 ? aws_db_subnet_group.db_subnet_group[0].name : null
  description = "DB subnet group name"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public Route Table Id"
}

output "vpc_cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "VPC CIDR Block"
}

output "vpc_endpoints" {
  value = {
    ecr_dkr = aws_vpc_endpoint.ecr_dkr.id
    ecr_api = aws_vpc_endpoint.ecr_api.id
    s3      = aws_vpc_endpoint.s3.id
    logs    = aws_vpc_endpoint.logs.id
  }
}

output "fargate_task_sg_id" {
  value       = aws_security_group.fargate_task_sg.id
  description = "Fargate task security group id"
}

