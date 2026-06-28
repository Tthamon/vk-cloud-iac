variable "project_name" {
  description = "Name project"
  type        = string
  default     = "new_project"
}

variable "my_ip" {
  description = "My ip-address"
  type        = string
  sensitive   = true
}

variable "s3_access_key" {
  description = "S3 access key in your account"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret key in your account"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Set the bucket name for the s3 storage after it is created"
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

variable "disk_size" {
  description = "Size of the disk in GB"
  type        = number
  default     = 10
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

variable "count_web" {
  description = "Number of web servers"
  type        = number
  default     = 2
}

variable "region" {
  description = "Region for backend"
  type        = string
  default     = "ru-msk"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "image_name" {
  description = "Base name of Packer image"
  type        = string
}