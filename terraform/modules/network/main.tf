terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
  }
}

# Создание сети
resource "vkcs_networking_network" "main" {
  name           = var.network_name
  admin_state_up = true
}

# Создание публичной подсети
resource "vkcs_networking_subnet" "public" {
  name       = "${var.network_name}-public-subnet"
  network_id = vkcs_networking_network.main.id
  cidr       = var.public_subnet_cidr
}

# Создание приватной подсети (веб)
resource "vkcs_networking_subnet" "private_web" {
  name       = "${var.network_name}-private-web-subnet"
  network_id = vkcs_networking_network.main.id
  cidr       = var.private_web_subnet_cidr
}

# Подсеть для БД
resource "vkcs_networking_subnet" "database" {
  name       = "${var.network_name}-database-subnet"
  network_id = vkcs_networking_network.main.id
  cidr       = var.database_subnet_cidr
}

# Data source для поиска внешней сети в VK Cloud
data "vkcs_networking_network" "external" {
  name = var.external_network_name
}

# Создание роутера для доступа в интернет
resource "vkcs_networking_router" "router" {
  name                = "${var.network_name}-router"
  admin_state_up      = true
  external_network_id = data.vkcs_networking_network.external.id
}

# Подключение публичной подсети к роутеру
resource "vkcs_networking_router_interface" "public" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.public.id
}

# Подключение приватной подсети к роутеру
resource "vkcs_networking_router_interface" "private_web" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.private_web.id
}

# Подключение подсети БД к роутеру
resource "vkcs_networking_router_interface" "database" {
  router_id = vkcs_networking_router.router.id
  subnet_id = vkcs_networking_subnet.database.id
}