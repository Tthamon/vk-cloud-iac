output "keypair_name" {
  value = vkcs_compute_keypair.my_key.name
}

output "bastion_floating_ip" {
  value = vkcs_networking_floatingip.bastion.address
}

output "web_instance_ips" {
  value = vkcs_compute_instance.web[*].access_ip_v4
}

output "web_instance_names" {
  value = vkcs_compute_instance.web[*].name
}

output "web_ports" {
  value = vkcs_networking_port.web_port[*].id
}

output "image_id" {
  value = data.vkcs_images_image.custom.id
}