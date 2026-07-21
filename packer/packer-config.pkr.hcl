packer {
  required_plugins {
    openstack = {
      source  = "github.com/hashicorp/openstack"
      version = "~> 1"
    }
  }
}

# Источник (source) — параметры образа
source "openstack" "ubuntu-nginx" {
  identity_endpoint    = var.os_auth_url
  username    = var.os_username
  password    = var.os_password
  tenant_id   = var.os_project_id
  domain_name = var.os_domain_name
  region      = "RegionOne"

  source_image = var.base_image_id
  flavor = var.flavor_type
  networks = [var.network_id]
  security_groups   = ["default", "packer-ssh"]  
  ssh_username = "ubuntu"  
  image_name = "${var.image_name}"
    
  volume_type = "ceph-ssd"
  volume_size = 10
  use_blockstorage_volume = true
  
  availability_zone = "MS1"

  use_floating_ip = true
  floating_ip_network = "ec8c610e-6387-447e-83d2-d2c541e88164"
}

# Сборка
build {
  sources = ["source.openstack.ubuntu-nginx"]

  # Провизоры (provisioners) — команды для настройки
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx",
      "sudo systemctl enable nginx",
      
      "echo 'Creating test page...'",
      "echo '<h1>Hello from Packer!</h1>' | sudo tee /var/www/html/index.html",
      
      "echo 'Cleaning up...'",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/lib/apt/lists/*"
    ]
  }
}