# Поиск flavor по имени
data "vkcs_compute_flavor" "data_flavor" {
  name = "STD2-2-8"
}

# Управляемый инстанс PostgreSQL
resource "vkcs_db_instance" "postgres" {
  name              = "${var.project_name}-postgres"
  flavor_id         = data.vkcs_compute_flavor.data_flavor.id
  size              = var.disk_size
  volume_type       = "ceph-ssd"
  availability_zone = "MS1"

  datastore {
    type    = "postgresql"
    version = "15"
  }

  network {
    uuid      = vkcs_networking_network.main.id
    subnet_id = vkcs_networking_subnet.database.id
  }

  depends_on = [vkcs_networking_router_interface.database]
}

# Создаем базу данных внутри инстанса
resource "vkcs_db_database" "my_database" {
  name    = "app_database"
  dbms_id = vkcs_db_instance.postgres.id
}

# Создаем пользователя и назначаем права
resource "vkcs_db_user" "my_user" {
  name     = "app_user"
  password = var.db_password
  dbms_id  = vkcs_db_instance.postgres.id
}
