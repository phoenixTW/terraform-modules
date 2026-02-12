resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags, { "Name" = local.resource_prefix })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.tags, {
    "type" = "private"
    "Name" = "${local.resource_prefix}.subnet.private.${count.index + 1}"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = var.enable_public_ip_on_launch

  tags = merge(var.tags, {
    "type" = "public"
    "Name" = "${local.resource_prefix}.subnet.public.${count.index + 1}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    "Name" = "${local.resource_prefix}.internet-gateway"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags,
    { "Name" = "${local.resource_prefix}.route-table.public" }
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count      = length(var.availability_zones)
  domain     = "vpc"
  depends_on = [aws_route_table.public, aws_internet_gateway.igw, aws_route_table_association.public]
  tags = merge(var.tags,
    { "Name" = "${local.resource_prefix}.eip.nat-gateway" }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw, aws_eip.nat]
  tags = merge(var.tags,
    { "Name" = "${local.resource_prefix}.nat-gateway" }
  )
}

resource "aws_route_table" "private_nat" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = merge(var.tags,
    { "Name" = "${local.resource_prefix}.route-table.private" }
  )
}

resource "aws_route_table_association" "private_nat" {
  count          = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_nat[length(var.availability_zones) > 1 ? count.index : 0].id
}

resource "aws_subnet" "database" {
  count                   = length(var.database_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.database_subnets[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, { "type" = "database" }, {
    "Name" = "${local.resource_prefix}.subnet.database" }
  )
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count      = length(var.database_subnets) > 0 ? 1 : 0
  name       = "${var.service_name}-${var.env}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  tags = merge(var.tags,
    { "Name" = "${local.resource_prefix}.db-subnet-group" }
  )
}

resource "aws_route_table_association" "database_nat" {
  count          = length(var.database_subnets)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private_nat[length(var.availability_zones) > 1 ? count.index : 0].id
}

