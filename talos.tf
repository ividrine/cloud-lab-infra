locals {

  cluster_internal_endpoint = "https://${var.cluster_domain}:6443"

  cluster_network = {
    dnsDomain      = var.cluster_domain
    podSubnets     = [var.pod_ipv4_cidr]
    serviceSubnets = [var.service_ipv4_cidr]
    cni            = { name = "none" }
  }

  proxy = {
    disabled = true
  }

  features = {
    hostDNS = {
      enabled              = true
      forwardKubeDNSToHost = false
      resolveMemberNames   = true
    }
  }

  extra_host_entries = [
    {
      ip      = local.control_plane_private_vip_ipv4
      aliases = [var.cluster_domain]
    }
  ]

  kubelet = {
    extraArgs = merge(
      {
        "cloud-provider"             = "external"
        "rotate-server-certificates" = true
      }
    )
    nodeIP = { validSubnets = [var.node_subnet_ipv4_cidr] }
  }

  hcloud_secret_manifest = {
    name = "hcloud-secret"
    contents = yamlencode({
      apiVersion = "v1"
      kind       = "Secret"
      type       = "Opaque"
      metadata = {
        name      = "hcloud"
        namespace = "kube-system"
      }
      data = {
        network = base64encode(local.hcloud_network_id)
        token   = base64encode(var.hcloud_token)
      }
    })
  }

  tailscale_patch = yamlencode({
    apiVersion = "v1alpha1"
    kind       = "ExtensionServiceConfig"
    name       = "tailscale"
    environment = [
      "TS_AUTHKEY=${var.tailscale_authkey}"
    ]
  })

  control_plane_config_patch = {
    for node in local.control_planes : node.name => {
      machine = {
        network = {
          hostname = node.name
          interfaces = [
            {
              # Todo configure public interface vip
              interface = "eth0"
              dhcp      = true
            },
            {
              interface = "eth1"
              dhcp      = true
              vip = {
                ip = local.control_plane_private_vip_ipv4
                hcloud = {
                  apiToken = var.hcloud_token
                }
              }
            }
          ]
          extraHostEntries = local.extra_host_entries
        }
        kubelet  = local.kubelet
        features = local.features
      }
      cluster = {
        proxy   = local.proxy
        network = local.cluster_network
        controllerManager = {
          extraArgs = {
            "cloud-provider" = "external"
            "bind-address"   = "0.0.0.0"
          }
        }
        etcd = {
          advertisedSubnets = [var.node_subnet_ipv4_cidr]
          extraArgs         = { "listen-metrics-urls" = "http://0.0.0.0:2381" }
        }
        scheduler       = { extraArgs = { "bind-address" = "0.0.0.0" } }
        inlineManifests = [local.hcloud_secret_manifest]
        externalCloudProvider = {
          enabled = true
        }
      }
    }
  }

  worker_config_patch = {
    for node in local.workers : node.name => {
      machine = {
        network = {
          hostname         = node.name
          extraHostEntries = local.extra_host_entries
          interfaces = [
            {
              interface = "eth0"
              dhcp      = true
            }
          ]
        }
        kubelet  = local.kubelet
        features = local.features
      }
      cluster = {
        network = local.cluster_network
        proxy   = local.proxy
      }
    }
  }

}

resource "talos_machine_secrets" "secrets" {}

data "talos_machine_configuration" "control_plane" {
  for_each         = { for control_plane in local.control_planes : control_plane.name => control_plane }
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  cluster_endpoint = local.cluster_internal_endpoint
  config_patches   = [yamlencode(local.control_plane_config_patch[each.value.name]), local.tailscale_patch]
}

data "talos_machine_configuration" "worker" {
  for_each         = { for worker in local.workers : worker.name => worker }
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  cluster_endpoint = local.cluster_internal_endpoint
  config_patches   = [yamlencode(local.worker_config_patch[each.value.name]), local.tailscale_patch]
}

resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoint             = local.control_plane_public_ipv4_list[0]
  node                 = local.control_plane_public_ipv4_list[0]
  depends_on           = [hcloud_server.control_plane]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = local.control_plane_public_ipv4_list[0]
  depends_on           = [talos_machine_bootstrap.bootstrap]
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}