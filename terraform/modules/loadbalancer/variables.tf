variable "project_name" {
  description = "Name project"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "web_instance_ips" {
  description = "List of web instance IPs"
  type        = list(string)
}

variable "web_instance_count" {
  description = "Number of web instances"
  type        = number
}

variable "http_port" {
  description = "HTTP port number"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "HTTP"
}

variable "pool_protocol" {
  description = "Pool protocol"
  type        = string
  default     = "HTTP"
}

variable "lb_method" {
  description = "Load balancing method"
  type        = string
  default     = "ROUND_ROBIN"
}

variable "monitor_type" {
  description = "Monitor type"
  type        = string
  default     = "HTTP"
}

variable "monitor_url_path" {
  description = "Monitor URL path"
  type        = string
  default     = "/"
}

variable "health_delay" {
  description = "The interval between checks"
  type        = number
  default     = 10
}

variable "health_timeout" {
  description = "Response waiting time"
  type        = number
  default     = 5
}

variable "health_max_retries" {
  description = "The maximum number of failed checks"
  type        = number
  default     = 3
}

variable "floating_ip_pool" {
  description = "Floating IP pool name"
  type        = string
  default     = "internet"
}