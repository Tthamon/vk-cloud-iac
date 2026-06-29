output "db_instance_id" {
  value = vkcs_db_instance.postgres.id
}

output "db_name" {
  value = vkcs_db_database.my_database.name
}

output "db_host" {
  value = vkcs_db_instance.postgres.ip
}

output "db_port" {
  value = 5432
}