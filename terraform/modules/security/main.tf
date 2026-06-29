terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
  }
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

# SG для Web
resource "vkcs_networking_secgroup" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web server security group"
}

resource "vkcs_networking_secgroup_rule" "web_ssh" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.bastion_subnet_cidr
  security_group_id = vkcs_networking_secgroup.web.id
}

resource "vkcs_networking_secgroup_rule" "web_http" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.http_port
  port_range_max    = var.http_port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = vkcs_networking_secgroup.web.id
}

resource "vkcs_networking_secgroup_rule" "web_node_exporter" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.nodexp_port
  port_range_max    = var.nodexp_port
  remote_ip_prefix  = var.bastion_subnet_cidr
  security_group_id = vkcs_networking_secgroup.web.id
}

# SG для БД
resource "vkcs_networking_secgroup" "database" {
  name        = "${var.project_name}-db-sg"
  description = "Database security group"
}

resource "vkcs_networking_secgroup_rule" "db_postgres" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.postgres_port
  port_range_max    = var.postgres_port
  remote_ip_prefix  = var.web_subnet_cidr
  security_group_id = vkcs_networking_secgroup.database.id
}

resource "vkcs_networking_secgroup_rule" "db_ssh" {
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.bastion_subnet_cidr
  security_group_id = vkcs_networking_secgroup.database.id
}