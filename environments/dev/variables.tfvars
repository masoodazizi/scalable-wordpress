env = "dev"

region = "eu-central-1"

create_vpc = true

# if "create_vpc = false", the following variables must be defined:
# vpc_id = ""
# private_subnet_ids = ""
# public_subnet_ids = ""

tags = {
  Environment = "dev"
  Project     = "scwp"
}
