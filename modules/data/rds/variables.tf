variable "env" {}

variable "vpc_id" {}

variable "private_subnets" {}

variable "engine" {
  default = "aurora-mysql"
}

variable "engine_version" {
  default = "5.7.mysql_aurora.2.09.0"
  # default = "5.6.mysql_aurora.1.19.0"
}

variable "database_name" {
  default = "wordpress"
}

variable "master_username" {}

variable "master_password" {}

variable "backup_retention_period" {
  default = 5
}

variable "preferred_backup_window" {
  default = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  default = "Wed:04:00-Wed:05:30"
}

variable "instance_class" {
  default = "db.t3.small"
}

variable "tags" {
  type = map(string)
}
