locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "network" {
  source      = "../../modules/network"
  name_prefix = local.name_prefix
}

module "storage" {
  source      = "../../modules/storage"
  name_prefix = local.name_prefix
}

module "compute" {
  source       = "../../modules/compute"
  name_prefix  = local.name_prefix
  network_name = module.network.network_name # output of one module feeds another
  volume_name  = module.storage.volume_name
  host_port    = var.host_port
}
