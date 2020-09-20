resource "aws_rds_cluster_instance" "aurora" {
  identifier           = "${var.env}-wp-aurora-cluster-instance"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-aurora-cluster-instance"
    }
  )
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.env}-wp-aurora-cluster"
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password

  vpc_security_group_ids    = [aws_security_group.aurora.id]
  db_subnet_group_name      = aws_db_subnet_group.aurora.id
  final_snapshot_identifier = "${var.env}-wp-db-final-snapshot"

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-aurora-cluster"
    }
  )
}

resource "aws_db_subnet_group" "aurora" {
  name        = "${var.env}-wp-aurora-subnets"
  subnet_ids  = split(",", var.private_subnets)
  description = "Subnet Group for ${var.env}-wp-aurora-cluster"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-aurora-subnets"
    }
  )
}

resource "aws_security_group" "aurora" {
  name        = "${var.env}-wp-aurora-sg"
  description = "Security Group for ${var.env}-wp-aurora-cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env}-wp-aurora-sg"
    }
  )
}
