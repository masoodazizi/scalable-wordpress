terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    encrypt = true
  }

  required_version = "~> 0.13"
}
