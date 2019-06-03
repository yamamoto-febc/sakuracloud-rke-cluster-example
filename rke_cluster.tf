resource rke_cluster "cluster" {
  delay_on_creation     = 30
  ignore_docker_version = true

  services_kubelet {
    extra_args = {
      cloud-provider = "external"
    }
  }

  ingress {
    provider = "none"
  }

  addon_job_timeout = 60
  addons            = data.template_file.init.rendered

  dynamic nodes {
    for_each = module.nodes.server_ipaddresses
    content {
      address           = module.nodes.server_ipaddresses[nodes.key]
      hostname_override = module.nodes.server_names[nodes.key]
      user              = "rancher"
      role              = ["controlplane", "worker", "etcd"]
      ssh_key           = file("~/.ssh/id_rsa")
    }
  }
}

data template_file "init" {
  template = file("manifest.yaml")
  vars = {
    access_token        = base64encode(var.sakuracloud_access_token)
    access_token_secret = base64encode(var.sakuracloud_access_token_secret)
    zone                = var.sakuracloud_zone
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.module}/kube_config_cluster.yml"

  content = rke_cluster.cluster.kube_config_yaml
}
