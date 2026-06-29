output "vm_ip" {
  value = module.compute.web_instance_ips
}

output "vm_name" {
  value = module.compute.web_instance_names
}

output "web_servers_ips" {
  value = module.compute.web_instance_ips
}

output "db_name" {
  value = module.database.db_name
}

output "db_host" {
  value = module.database.db_host
}

output "db_port" {
  value = module.database.db_port
}

output "network_id" {
  value = module.network.network_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_web_subnet_id
}

output "database_subnet_id" {
  value = module.network.database_subnet_id
}

output "bastion_ip" {
  value = module.compute.bastion_floating_ip
}

output "load_balancer_ip" {
  value = module.loadbalancer.load_balancer_ip
}
