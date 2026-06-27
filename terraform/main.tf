provider "vkcs" {
  # Переменные окружения будут использованы автоматически
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
  remote_ip_prefix  = var.my_ip
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

# Получение имени созданного через Packer образа
data "local_file" "image_name" {
  filename = "${path.module}/../packer/image_name.txt"
}

# Поиск созданного образа
data "vkcs_images_image" "custom" {
  name        = trimspace(data.local_file.image_name.content)
  most_recent = true
}

# Имя flavor для ВМ
data "vkcs_compute_flavor" "my_flavor" {
  name = "Basic-1-1-10"
}

# Создание виртуальной машины
resource "vkcs_compute_instance" "web" {
  count           = var.count_web
  name            = "${var.project_name}-custom-image-${count.index + 1}"
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
