output "bastion_security_group_id" {
  value = vkcs_networking_secgroup.bastion.id
}

output "web_security_group_id" {
  value = vkcs_networking_secgroup.web.id
}

output "database_security_group_id" {
  value = vkcs_networking_secgroup.database.id
}