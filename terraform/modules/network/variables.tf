variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "private_web_subnet_cidr" {
  description = "CIDR for private web subnet"
  type        = string
  default     = "192.168.2.0/24"
}

variable "database_subnet_cidr" {
  description = "CIDR for database subnet"
  type        = string
  default     = "192.168.3.0/24"
}

variable "external_network_name" {
  description = "Name of the external network in VK Cloud"
  type        = string
  default     = "internet"
}