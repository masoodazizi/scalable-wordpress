module "network" {
  count  = var.create_vpc ? 1 : 0
  source = "./modules/network"

  env  = var.env
  tags = var.tags
}
