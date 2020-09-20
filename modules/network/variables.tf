variable "env" {}

variable "cidr_block" {
  description = "Defines the CIDR for the whole VPC"
  default     = "10.10.0.0/16"
}

variable "tags" {
  type = map(string)
}

variable "public_subnets_cidrs" {
  default     = ["10.10.20.0/24", "10.10.21.0/24"]
  description = "Comma separated list of subnets"
}

variable "private_subnets_cidrs" {
  default     = ["10.10.10.0/24", "10.10.11.0/24"]
  description = "Comma separated list of subnets"
}
