
terraform {
  required_version = ">= 0.12"
  backend "local" {}
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  version = "~> 2.46.0"
}
