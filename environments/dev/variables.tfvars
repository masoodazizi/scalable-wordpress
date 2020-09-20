env = "dev"

region = "eu-central-1"

create_vpc = true

tags = {
  Environment = "dev"
  Project     = "scwp"
}

# create all vpc resources including subnets, gateways and routings
# if vpc resources are already existing, then
# "create_vpc = false", and the following variables must be defined:
# vpc_id = ""
# private_subnets = ""
# public_subnets = ""


# if the bastion host is not needed, uncomment this variable
# create_bastion = false


# if https listener is required for the ALB, uncomment 'enable_alb_https = true', and define 'certificate_arn'
# enable_alb_https = true
# certificate_arn = ""


# if additional IPs required ssh access. The public ip of the current user (var.my_ip) fetched automatically.
# custom_ips = []


# These two variables are defined via deploy script
# ssh_pub_key = ""
# userdata = ""

