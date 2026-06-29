terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
  }
}

# Поиск flavor по имени
data "vkcs_compute_flavor" "db_flavor" {
  name = var.db_flavor_name
}

# Управляемый инстанс PostgreSQL
resource "vkcs_db_instance" "postgres" {
  name              = "${var.project_name}-postgres"
  flavor_id         = data.vkcs_compute_flavor.db_flavor.id
  size              = var.disk_size
  volume_type       = var.volume_type
  availability_zone = var.availability_zone

  datastore {
    type    = "postgresql"
    version = var.db_version
  }

  network {
    uuid      = var.network_id
    subnet_id = var.database_subnet_id
  }

  depends_on = [var.router_interface_depends_on]
}

# Создаем базу данных внутри инстанса
resource "vkcs_db_database" "my_database" {
  name    = var.database_name
  dbms_id = vkcs_db_instance.postgres.id
}

# Создаем пользователя и назначаем права
resource "vkcs_db_user" "my_user" {
  name     = var.database_user
  password = var.db_password
  dbms_id  = vkcs_db_instance.postgres.id
}