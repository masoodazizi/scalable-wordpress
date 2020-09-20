resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_vpc"
    },
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_subnet_pub_${count.index}"
    },
  )
}

resource "aws_subnet" "private" {
  count      = length(var.private_subnets_cidrs)
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_subnets_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_subnet_prv_${count.index}"
    },
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_ig"
    },
  )
}

resource "aws_nat_gateway" "this" {
  # count         = "${length(var.private_subnets_cidrs)}"
  subnet_id = element(aws_subnet.public.*.id, 0)

  # allocation_id = "${element(aws_eip.*.id), count.index}"
  allocation_id = aws_eip.nat_ip.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_ng"
    },
  )
}

resource "aws_eip" "nat_ip" {
  # count = "${length(var.private_subnets_cidrs)}"
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_nat_ip"
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_public_rt"
    },
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}_private_rt"
    },
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
