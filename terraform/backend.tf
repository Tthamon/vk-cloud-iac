terraform {
  backend "s3" {
    key                         = "terraform.tfstate"
    region                      = "ru-msk"
    endpoints                   = { s3 = "https://hb.ru-msk.vkcloud-storage.ru" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
  }
}
