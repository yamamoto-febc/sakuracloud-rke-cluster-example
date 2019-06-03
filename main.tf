provider sakuracloud {
  token               = var.sakuracloud_access_token
  secret              = var.sakuracloud_access_token_secret
  zone                = var.sakuracloud_zone
  api_request_timeout = 300
}