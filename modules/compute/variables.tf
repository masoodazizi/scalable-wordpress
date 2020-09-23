variable "env" {}

variable "vpc_id" {}

variable "private_subnets" {}

variable "public_subnets" {}

variable "access_cidrs" {
  default     = [""]
  description = "List of CIDRS of public IP addresses accessing to the resources"
}

variable "ssh_pub_key" {
  default = ""
}

variable "instance_type" {
  default = "t3.micro"
}

variable "root_volume_size" {
  default = "10"
}

variable "wp_name" {
  default = "scwp"
}

variable "wp_init" {
  default = false
}

variable "wp_region" {}

variable "wp_efs_id" {}

variable "wp_db_host" {}

variable "wp_db_name" {}

variable "wp_db_user" {}

variable "wp_db_password" {}

variable "aurora_sg" {}

variable "efs_sg" {}


variable "create_bastion" {
  default = true
}

variable "enable_alb_https" {
  default = false
}

variable "certificate_arn" {
  default = ""
}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-2016-08"
}

variable "tags" {
  type = map(string)
}

##### AUTO SCALING GROUP VARIABLES

variable "asg_min_size" {
  # default = "0"
  default = "1"
}

variable "asg_max_size" {
  default = "5"
}

variable "asg_desired_capacity" {
  #default = "0"
  default = "2"
}

variable "asg_health_check_type" {
  default = "EC2"
  # default = "ELB"
}

variable "asg_health_check_grace_period" {
  default = "300"
}
