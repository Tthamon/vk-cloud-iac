# Балансировщик нагрузки
resource "vkcs_lb_loadbalancer" "main" {
  name          = "${var.project_name}-lb"
  vip_subnet_id = vkcs_networking_subnet.public.id
}

# Слушатель
resource "vkcs_lb_listener" "http" {
  name            = "${var.project_name}-listener"
  protocol        = "HTTP"
  protocol_port   = var.http_port
  loadbalancer_id = vkcs_lb_loadbalancer.main.id
}

# Целевая группа (пул)
resource "vkcs_lb_pool" "web" {
  name        = "web-pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = vkcs_lb_listener.http.id
}

# Проверка здоровья
resource "vkcs_lb_monitor" "web" {
  name        = "${var.project_name}-monitor"
  type        = "HTTP"
  delay       = var.health_delay
  timeout     = var.health_timeout
  max_retries = var.health_max_retries
  url_path    = "/"
  pool_id     = vkcs_lb_pool.web.id
}

# Член пула балансировщика
resource "vkcs_lb_member" "web" {
  count         = var.count_web
  name          = "${var.project_name}-member-${count.index + 1}"
  address       = vkcs_compute_instance.web[count.index].access_ip_v4
  protocol_port = var.http_port
  pool_id       = vkcs_lb_pool.web.id
  subnet_id     = vkcs_networking_subnet.public.id
}

# Публичный IP-адрес
resource "vkcs_networking_floatingip" "fip" {
  pool = "internet"
}

# Привязка IP к балансировщику
resource "vkcs_networking_floatingip_associate" "lb" {
  floating_ip = vkcs_networking_floatingip.fip.address
  port_id     = vkcs_lb_loadbalancer.main.vip_port_id
}
