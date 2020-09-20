resource "aws_efs_file_system" "efs" {
  creation_token = "${var.env}-wp-efs"

  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_mibps

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-efs"
    }
  )
}

resource "aws_efs_mount_target" "efs" {
  file_system_id = aws_efs_file_system.efs.id

  count           = length(split(",", var.private_subnets))
  subnet_id       = element(split(",", var.private_subnets), count.index)
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name   = "${var.env}-wp-efs-sg"
  vpc_id = "${var.vpc_id}"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-efs-sg"
    }
  )
}
