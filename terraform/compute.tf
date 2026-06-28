# Создание SSH-ключа
resource "vkcs_compute_keypair" "my_key" {
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key

  lifecycle {
    ignore_changes = [public_key]
  }
}

# Поиск id инстанса БД
data "vkcs_db_instance" "postgres" {
  id = vkcs_db_instance.postgres.id
}

# Порт для веб-серверов в приватной подсети
resource "vkcs_networking_port" "web_port" {
  count              = var.count_web
  name               = "web-port-${count.index + 1}"
  network_id         = vkcs_networking_network.main.id
  security_group_ids = [vkcs_networking_secgroup.web.id]
  fixed_ip {
    subnet_id = vkcs_networking_subnet.private.id
  }
}

# Порт для Bastion в публичной подсети
resource "vkcs_networking_port" "bastion_port" {
  name               = "bastion-port"
  network_id         = vkcs_networking_network.main.id
  security_group_ids = [vkcs_networking_secgroup.bastion.id]
  fixed_ip {
    subnet_id = vkcs_networking_subnet.public.id
  }
}

resource "vkcs_networking_floatingip" "bastion" {
  pool = "internet"
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