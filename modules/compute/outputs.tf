output "bastion_sg" {
  value = aws_security_group.bastion[0].id
}

output "alb_sg" {
  value = aws_security_group.alb.id
}

output "instance_sg" {
  value = aws_security_group.instance.id
}
