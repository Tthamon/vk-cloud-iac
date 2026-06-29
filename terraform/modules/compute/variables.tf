variable "project_name" {
  description = "Name project"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "image_name" {
  description = "Base name of Packer image"
  type        = string
}

variable "flavor_name" {
  description = "Flavor name for VMs"
  type        = string
  default     = "Basic-1-1-10"
}

variable "web_instance_count" {
  description = "Number of web instances"
  type        = number
  default     = 2
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_web_subnet_id" {
  description = "ID of the private web subnet"
  type        = string
}

variable "bastion_security_group_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "web_security_group_id" {
  description = "ID of the web security group"
  type        = string
}

variable "floating_ip_pool" {
  description = "Floating IP pool name"
  type        = string
  default     = "internet"
}

variable "web_metadata" {
  description = "Metadata for web instances"
  type        = map(string)
  default = {
    environment = "dev"
    created_by  = "terraform"
  }
}