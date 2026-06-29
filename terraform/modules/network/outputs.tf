output "network_id" {
  value = vkcs_networking_network.main.id
}

output "public_subnet_id" {
  value = vkcs_networking_subnet.public.id
}

output "private_web_subnet_id" {
  value = vkcs_networking_subnet.private_web.id
}

output "database_subnet_id" {
  value = vkcs_networking_subnet.database.id
}

output "router_id" {
  value = vkcs_networking_router.router.id
}

output "external_network_id" {
  value = data.vkcs_networking_network.external.id
}

output "database_router_interface" {
  value = vkcs_networking_router_interface.database
}