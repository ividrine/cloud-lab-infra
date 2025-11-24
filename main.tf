# https://registry.terraform.io/modules/hcloud-talos/talos/hcloud/latest

locals {
  cilium_values = [yamlencode({
    gatewayApi = { 
      enabled = true 
    }
  })]
}

module "talos" {
  source = "hcloud-talos/talos/hcloud"
  version = "2.20.4"

  # Core 
  talos_version = "v1.11.0"
  kubernetes_version = "1.33.6"
  cilium_version     = "1.18.4"
  cilium_values = [yamlencode({
    
  })]

  # Hetzner token
  hcloud_token = var.hcloud_token
  
  # Firewall
  firewall_use_current_ip = true

  # Cluster Name / DNS
  cluster_name     = "cloud-lab"
  cluster_domain   = "cluster.dummy.com.local"
  cluster_api_host = "kube.com"

  # Servers location
  datacenter_name = var.datacenter_name

  # Control plane
  control_plane_count = 1
  control_plane_server_type = "cx23"

  # Workers

  worker_nodes = [
    {
      type  = "cx23"
      labels = {
        "node.kubernetes.io/instance-type" = "cx23"
      }
    },
    {
      type  = "cx22"
      labels = {
        "node.kubernetes.io/instance-type" = "cx23"
      }
    }
  ]

  # Networking

  network_ipv4_cidr = "10.0.0.0/16"
  node_ipv4_cidr    = "10.0.1.0/24"
  pod_ipv4_cidr     = "10.0.16.0/20"
  service_ipv4_cidr = "10.0.8.0/21"

  # Add all nodes to the tailscale network

  tailscale = {
    enabled  = true
    auth_key = var.tailscale_auth_key
  }

  output_mode_config_cluster_endpoint = "private_ip"
  
}