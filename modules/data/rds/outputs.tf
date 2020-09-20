output "aurora_sg" {
  value = aws_security_group.aurora.id
}

output "endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}
