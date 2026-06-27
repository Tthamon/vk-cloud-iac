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

# Порт для публичной подсети
resource "vkcs_networking_port" "web_port" {
  count              = var.count_web
  name               = "web-port-${count.index + 1}"
  network_id         = vkcs_networking_network.main.id
  security_group_ids = [vkcs_networking_secgroup.web.id]
  fixed_ip {
    subnet_id = vkcs_networking_subnet.public.id
  }
}
