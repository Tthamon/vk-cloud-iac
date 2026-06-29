terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
  }
}

# Создание SSH-ключа
resource "vkcs_compute_keypair" "my_key" {
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
  lifecycle {
    ignore_changes = [public_key]
  }
}

# Data sources для образа и flavor
data "vkcs_images_image" "custom" {
  name        = var.image_name
  most_recent = true
}

data "vkcs_compute_flavor" "my_flavor" {
  name = var.flavor_name
}

# Порт для веб-серверов в приватной подсети
resource "vkcs_networking_port" "web_port" {
  count              = var.web_instance_count
  name               = "web-port-${count.index + 1}"
  network_id         = var.network_id
  security_group_ids = [var.web_security_group_id]
  fixed_ip {
    subnet_id = var.private_web_subnet_id
  }
}

# Порт для Bastion в публичной подсети
resource "vkcs_networking_port" "bastion_port" {
  name               = "bastion-port"
  network_id         = var.network_id
  security_group_ids = [var.bastion_security_group_id]
  fixed_ip {
    subnet_id = var.public_subnet_id
  }
}

# Floating IP для Bastion
resource "vkcs_networking_floatingip" "bastion" {
  pool = var.floating_ip_pool
}

resource "vkcs_networking_floatingip_associate" "bastion" {
  floating_ip = vkcs_networking_floatingip.bastion.address
  port_id     = vkcs_networking_port.bastion_port.id
}

# Bastion ВМ
resource "vkcs_compute_instance" "bastion" {
  name      = "${var.project_name}-bastion"
  image_id  = data.vkcs_images_image.custom.id
  flavor_id = data.vkcs_compute_flavor.my_flavor.id
  key_pair  = vkcs_compute_keypair.my_key.name

  network {
    port = vkcs_networking_port.bastion_port.id
  }

  metadata = {
    role = "bastion"
  }
}

# Веб-серверы
resource "vkcs_compute_instance" "web" {
  count           = var.web_instance_count
  name            = "${var.project_name}-web-${count.index + 1}"
  image_id        = data.vkcs_images_image.custom.id
  flavor_id       = data.vkcs_compute_flavor.my_flavor.id
  key_pair        = vkcs_compute_keypair.my_key.name
  security_groups = [var.web_security_group_id]

  network {
    port = vkcs_networking_port.web_port[count.index].id
  }

  metadata = var.web_metadata
}