locals {

  node_patch = yamlencode({
    cluster = {
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  })

  tailscale_patch = yamlencode({
    apiVersion = "v1alpha1"
    kind       = "ExtensionServiceConfig"
    name       = "tailscale"
    environment = [
      "TS_AUTHKEY=${var.tailscale_authkey}"
    ]
  })

  cluster_internal_endpoint = "https://${var.control_plane_internal_ip}:6443"
}

resource "talos_machine_secrets" "secrets" {}

data "talos_machine_configuration" "control_plane" {
  cluster_name = var.cluster_name
  machine_type = "controlplane"
  machine_secrets = talos_machine_secrets.secrets.machine_secrets
  cluster_endpoint = local.cluster_internal_endpoint
  config_patches = [local.node_patch, local.tailscale_patch]
}

data "talos_machine_configuration" "worker" {
  cluster_name = var.cluster_name
  machine_type = "worker"
  machine_secrets = talos_machine_secrets.secrets.machine_secrets
  cluster_endpoint = local.cluster_internal_endpoint
  config_patches = [local.node_patch, local.tailscale_patch]
}

resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoint = hcloud_server.control_plane.ipv4_address
  node = hcloud_server.control_plane.ipv4_address
  depends_on = [hcloud_server.control_plane]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node = hcloud_server.control_plane.ipv4_address
  depends_on = [talos_machine_bootstrap.bootstrap]
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}