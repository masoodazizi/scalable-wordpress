output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = join(",", aws_subnet.public.*.id)
}

output "private_subnets" {
  value = join(",", aws_subnet.private.*.id)
}

