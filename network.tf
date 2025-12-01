resource "hcloud_network" "this" {
  name     = var.cluster_name
  ip_range = var.network_ipv4_cidr
}

resource "hcloud_network_subnet" "node" {
  type         = "cloud"
  network_id   = hcloud_network.this.id
  network_zone = var.node_subnet_zone
  ip_range     = var.node_subnet_ipv4_cidr
}

locals {
  # Network id
  hcloud_network_id = hcloud_network.this.id

  # Control plane private VIP
  control_plane_private_vip_ipv4 = cidrhost(hcloud_network_subnet.node.ip_range, -2)

  # Control plane IPs
  control_plane_public_ipv4_list  = [for control_plane in hcloud_server.control_plane : control_plane.ipv4_address]
  control_plane_private_ipv4_list = [for control_plane in hcloud_server.control_plane : tolist(control_plane.network)[0].ip]

  # Worker IPs
  worker_public_ipv4_list  = [for worker in hcloud_server.worker : worker.ipv4_address]
  worker_private_ipv4_list = [for worker in hcloud_server.worker : tolist(worker.network)[0].ip]
}

