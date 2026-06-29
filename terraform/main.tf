# Модуль network
module "network" {
  source = "./modules/network"

  network_name            = var.project_name
  public_subnet_cidr      = "192.168.1.0/24"
  private_web_subnet_cidr = "192.168.2.0/24"
  database_subnet_cidr    = "192.168.3.0/24"
  external_network_name   = "internet"
}

# Модуль Security
module "security" {
  source = "./modules/security"

  project_name        = var.project_name
  my_ip               = var.my_ip
  ssh_port            = var.ssh_port
  http_port           = var.http_port
  nodexp_port         = var.nodexp_port
  postgres_port       = var.postgres_port
  bastion_subnet_cidr = "192.168.1.0/24"
  web_subnet_cidr     = "192.168.2.0/24"
}

# Модуль compute
module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  ssh_public_key            = var.ssh_public_key
  image_name                = var.image_name
  flavor_name               = "Basic-1-1-10"
  web_instance_count        = var.count_web
  network_id                = module.network.network_id
  public_subnet_id          = module.network.public_subnet_id
  private_web_subnet_id     = module.network.private_web_subnet_id
  bastion_security_group_id = module.security.bastion_security_group_id
  web_security_group_id     = module.security.web_security_group_id
}

# Модуль database
module "database" {
  source = "./modules/database"

  project_name                = var.project_name
  db_flavor_name              = "STD2-2-8"
  disk_size                   = var.disk_size
  db_version                  = "15"
  network_id                  = module.network.network_id
  database_subnet_id          = module.network.database_subnet_id
  router_interface_depends_on = module.network.database_router_interface
  db_password                 = var.db_password
}

# Модуль loadbalancer
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name       = var.project_name
  public_subnet_id   = module.network.public_subnet_id
  web_instance_ips   = module.compute.web_instance_ips
  web_instance_count = var.count_web
  http_port          = var.http_port
}