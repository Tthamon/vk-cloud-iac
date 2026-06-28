provider "vkcs" {
  # Переменные окружения будут использованы автоматически
}

# SG для Bastion
resource "vkcs_networking_secgroup" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Bastion security group"
}

resource "vkcs_networking_secgroup_rule" "bastion_ssh" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.my_ip
  security_group_id = vkcs_networking_secgroup.bastion.id
}

# Создание Security Groups
resource "vkcs_networking_secgroup" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web server security group"
}

# Правила для SSH
resource "vkcs_networking_secgroup_rule" "web_ssh" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = "192.168.1.0/24"
  security_group_id = vkcs_networking_secgroup.web.id
}

# Правила для HTTP
resource "vkcs_networking_secgroup_rule" "web_http" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.http_port
  port_range_max    = var.http_port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = vkcs_networking_secgroup.web.id
}

# Правила для node exporter
resource "vkcs_networking_secgroup_rule" "web_node_exporter" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.nodexp_port
  port_range_max    = var.nodexp_port
  remote_ip_prefix  = "192.168.2.0/24"
  security_group_id = vkcs_networking_secgroup.web.id
}

# Security Group для БД
resource "vkcs_networking_secgroup" "database" {
  name        = "${var.project_name}-db-sg"
  description = "Database security group"
}

resource "vkcs_networking_secgroup_rule" "db_postgres" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.postgres_port
  port_range_max    = var.postgres_port
  remote_ip_prefix  = "192.168.2.0/24"  # только с веб-серверов
  security_group_id = vkcs_networking_secgroup.database.id
}

resource "vkcs_networking_secgroup_rule" "db_ssh" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = "192.168.1.0/24"  # только с bastion
  security_group_id = vkcs_networking_secgroup.database.id
}

# Поиск созданного образа
data "vkcs_images_image" "custom" {
  name        = var.image_name
  most_recent = true
}

# Имя flavor для ВМ
data "vkcs_compute_flavor" "my_flavor" {
  name = "Basic-1-1-10"
}

# Создание виртуальной машины
resource "vkcs_compute_instance" "web" {
  count           = var.count_web
  name            = "${var.project_name}-web-${count.index + 1}"
  image_id        = data.vkcs_images_image.custom.id
  flavor_id       = data.vkcs_compute_flavor.my_flavor.id
  image_name      = "ubuntu-24-202602051634.gite7a38aaf"
  key_pair        = vkcs_compute_keypair.my_key.name
  security_groups = [vkcs_networking_secgroup.web.id]

  network {
    port = vkcs_networking_port.web_port[count.index].id
  }

  metadata = {
    environment = "dev"
    created_by  = "terraform"
  }
}
