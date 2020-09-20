module "network" {
  count  = var.create_vpc ? 1 : 0
  source = "./modules/network"

  env  = var.env
  tags = var.tags
}

module "compute" {
  source = "./modules/compute"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets
  public_subnets = var.create_vpc ? module.network[0].public_subnets : var.public_subnets

  aurora_sg = module.aurora.aurora_sg
  aurora_endpoint = module.aurora.endpoint

  efs_sg = module.efs.efs_sg
  efs_id = module.efs.efs_id

  access_cidrs = concat([var.my_ip], var.custom_ips)
  ssh_pub_key = var.ssh_pub_key
  userdata = var.userdata
  create_bastion = var.create_bastion
  enable_alb_https = var.enable_alb_https
  certificate_arn = var.certificate_arn
}

module "aurora" {
  source = "./modules/data/rds"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets

  master_username = var.master_username
  master_password = var.master_password
}

module "efs" {
  source = "./modules/data/efs"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets
}

output "alb_address" {
  value = module.compute.alb_domain
}
