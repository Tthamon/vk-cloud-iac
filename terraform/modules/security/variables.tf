variable "project_name" {
  description = "Name project"
  type        = string
}

variable "my_ip" {
  description = "My ip-address"
  type        = string
}

variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "HTTP port number"
  type        = number
  default     = 80
}

variable "nodexp_port" {
  description = "Node Exporter port"
  type        = number
  default     = 9100
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "bastion_subnet_cidr" {
  description = "CIDR of the bastion subnet"
  type        = string
}

variable "web_subnet_cidr" {
  description = "CIDR of the web subnet"
  type        = string
}