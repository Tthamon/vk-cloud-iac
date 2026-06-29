terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.85.0"
    }
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.6.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = var.s3_access_key
  secret_key                  = var.s3_secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  endpoints {
    s3 = "https://hb.ru-msk.vkcloud-storage.ru"
  }
}

provider "vkcs" {
  # Переменные окружения будут использованы автоматически
}