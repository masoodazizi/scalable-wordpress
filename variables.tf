variable "env" {
  default = "dev"
}

variable "region" {
  default = ""
}

variable "create_vpc" {
  default = true
}

variable "tags" {
  default = {}
}

variable "vpc_id" {
  default = ""
}

variable "private_subnets" {
  default = ""
}

variable "public_subnets" {
  default = ""
}

variable "create_bastion" {
  default = true
}

variable "enable_alb_https" {
  default = false
}

variable "certificate_arn" {
  default = ""
}

variable "my_ip" {
  default = ""
}

variable "custom_ips" {
  default = []
}

variable "ssh_pub_key" {
  default = ""
}

variable "userdata" {
  default = "#userdata"
}

variable "master_username" {}

variable "master_password" {}
