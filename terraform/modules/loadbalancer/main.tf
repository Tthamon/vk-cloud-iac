terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
  }
}

# Балансировщик нагрузки
resource "vkcs_lb_loadbalancer" "main" {
  name          = "${var.project_name}-lb"
  vip_subnet_id = var.public_subnet_id
}

# Слушатель
resource "vkcs_lb_listener" "http" {
  name            = "${var.project_name}-listener"
  protocol        = var.listener_protocol
  protocol_port   = var.http_port
  loadbalancer_id = vkcs_lb_loadbalancer.main.id
}

# Целевая группа (пул)
resource "vkcs_lb_pool" "web" {
  name        = "web-pool"
  protocol    = var.pool_protocol
  lb_method   = var.lb_method
  listener_id = vkcs_lb_listener.http.id
}

# Проверка здоровья
resource "vkcs_lb_monitor" "web" {
  name        = "${var.project_name}-monitor"
  type        = var.monitor_type
  delay       = var.health_delay
  timeout     = var.health_timeout
  max_retries = var.health_max_retries
  url_path    = var.monitor_url_path
  pool_id     = vkcs_lb_pool.web.id
}

# Член пула балансировщика
resource "vkcs_lb_member" "web" {
  count         = var.web_instance_count
  name          = "${var.project_name}-member-${count.index + 1}"
  address       = var.web_instance_ips[count.index]
  protocol_port = var.http_port
  pool_id       = vkcs_lb_pool.web.id
  subnet_id     = var.public_subnet_id
}

# Публичный IP-адрес для балансировщика
resource "vkcs_networking_floatingip" "lb_fip" {
  pool = var.floating_ip_pool
}

# Привязка IP к балансировщику
resource "vkcs_networking_floatingip_associate" "lb" {
  floating_ip = vkcs_networking_floatingip.lb_fip.address
  port_id     = vkcs_lb_loadbalancer.main.vip_port_id
}