variable "env" {}
variable "private_subnets" {}
variable "vpc_id" {}

variable "throughput_mode" {
  default     = "bursting"
  description = "Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps"
}

variable "provisioned_mibps" {
  default = 0
}

variable "tags" {
  type = map(string)
}
