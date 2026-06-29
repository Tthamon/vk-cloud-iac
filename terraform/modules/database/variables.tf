variable "project_name" {
  description = "Name project"
  type        = string
}

variable "db_flavor_name" {
  description = "Flavor name for DB instance"
  type        = string
  default     = "STD2-2-8"
}

variable "disk_size" {
  description = "Size of the disk in GB"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Volume type for DB"
  type        = string
  default     = "ceph-ssd"
}

variable "availability_zone" {
  description = "Availability zone for DB"
  type        = string
  default     = "MS1"
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "database_subnet_id" {
  description = "ID of the database subnet"
  type        = string
}

variable "router_interface_depends_on" {
  description = "Resource to depend on for router interface"
  type        = any
  default     = null
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "app_database"
}

variable "database_user" {
  description = "Name of the database user"
  type        = string
  default     = "app_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}