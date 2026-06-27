# Создание сети
resource "vkcs_networking_network" "main" {
  name           = "${var.project_name}-vpc"
  admin_state_up = true
}

# Создание публичной подсети
resource "vkcs_networking_subnet" "public" {
  name       = "${var.project_name}-public-subnet"
  network_id = vkcs_networking_network.main.id
  cidr       = "192.168.1.0/24"
}

# Создание приватной подсети
resource "vkcs_networking_subnet" "private" {
  name       = "${var.project_name}-private-subnet"
  network_id = vkcs_networking_network.main.id
  cidr       = "192.168.2.0/24"
}

# Data source для поиска внешней сети в VK Cloud
data "vkcs_networking_network" "external" {
  name = "internet"
}

# Создание роутера для доступа в интернет
resource "vkcs_networking_router" "router" {
  name           = "${var.project_name}-router"
  admin_state_up = true

  # Внешняя сеть (предоставляется провайдером)
  external_network_id = data.vkcs_networking_network.external.id
}

# Подключение публичной подсети к роутеру
resource "vkcs_networking_router_interface" "public" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.public.id
}

# Подключение приватной подсети к роутеру
resource "vkcs_networking_router_interface" "private" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.private.id
}
