locals {
  node_count       = 3
  ssh_key          = file("~/.ssh/id_rsa.pub")
  node_name_prefix = "kubernetes-node"
}

resource sakuracloud_internet "router" {
  name        = "kubernetes-external-router"
  nw_mask_len = "28"
  band_width  = "100"
  tags        = ["@k8s"]
}

module "nodes" {
  source         = "sacloud/server/sakuracloud"
  version        = "0.4.0"
  server_count   = local.node_count
  os_type        = "rancheros"
  server_name    = local.node_name_prefix
  password       = var.server_password
  server_core    = 2
  server_memory  = 4
  nic            = sakuracloud_internet.router.switch_id
  ipaddress      = slice(sakuracloud_internet.router.ipaddresses, 0, local.node_count)
  nw_mask_len    = sakuracloud_internet.router.nw_mask_len
  gateway        = sakuracloud_internet.router.gateway
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}

