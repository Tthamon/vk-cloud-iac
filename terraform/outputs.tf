output "vm_ip" {
  value = vkcs_compute_instance.web[*].access_ip_v4
}

output "vm_name" {
  value = vkcs_compute_instance.web[*].name
}

output "web_servers_ips" {
  value = vkcs_compute_instance.web[*].access_ip_v4
}

output "db_name" {
  value = vkcs_db_database.my_database.name
}

output "db_host" {
  value = data.vkcs_db_instance.postgres.hostname
}

output "db_port" {
  value = 5432
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "network_id" {
  value = vkcs_networking_network.main.id
}

output "public_subnet_id" {
  value = vkcs_networking_subnet.public.id
}

output "private_subnet_id" {
  value = vkcs_networking_subnet.private.id
}

output "database_subnet_id" {
  value = vkcs_networking_subnet.database.id
}

output "bastion_ip" {
  value = vkcs_networking_floatingip.bastion.address
}

output "load_balancer_ip" {
  value = vkcs_networking_floatingip.fip.address
}
