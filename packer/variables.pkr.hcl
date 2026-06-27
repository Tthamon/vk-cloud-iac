variable "image_name" {
  type    = string
  default = "web-server-base"
}

variable "base_image_id" {
  type    = string
  default = "a4e699d3-a66d-45e5-bb5d-70ea7c8de62d"
}

variable "flavor_type" {
  type    = string
  default = "Basic-1-1-10"
}

# Переменные авторизации
variable "os_auth_url" {
  type    = string
  default = "https://infra.mail.ru/identity/v3"
}

variable "os_username" {
  type      = string
  sensitive = true
}

variable "os_password" {
  type      = string
  sensitive = true
}

variable "os_project_id" {
  type      = string
  sensitive = true
}

variable "os_domain_name" {
  type    = string
  default = "users"
}

variable "network_id" {
  type    = string
  default = ""
}