variable "aws_profile" {}
variable "aws_region" {}

variable "env" {
  default = "dev"
}

variable "project_name" {
  default = "scwp"
}

variable "ssh_key_path" {
  default = "../environments/dev/.secrets/ssh-key"
}

variable "create_sshkey" {
  default = 0
}

resource "random_string" "random_number" {
    length = 6
    min_numeric = 6
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-remote-state-${random_string.random_number.result}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  depends_on = [random_string.random_number]
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "null_resource" "key_gen" {
  count = var.create_sshkey ? 1 : 0
  provisioner "local-exec" {
    command     = "ssh-keygen -b 2048 -t rsa -f '${var.ssh_key_path}' -q -N '' -C 'ssh key for ${var.env} env'"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "local_file" "ssh_public_key" {
  filename = "${var.ssh_key_path}.pub"

  depends_on = [null_resource.key_gen]
}

output "ssh_key" {
  value = data.local_file.ssh_public_key.content
}

output "terraform_state_bucket" {
  value = aws_s3_bucket.terraform_state.id
}
