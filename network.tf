resource "hcloud_network" "cloud_network" {
  name     = var.cluster_name
  ip_range = var.network_ipv4_cidr
}

resource "hcloud_network_subnet" "node_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.cloud_network.id
  network_zone = var.node_subnet_zone
  ip_range     = var.node_subnet_ipv4_cidr
}

locals {
  hcloud_network_id              = hcloud_network.cloud_network.id
  control_plane_private_vip_ipv4 = cidrhost(hcloud_network_subnet.node_subnet.ip_range, -2)
  control_plane_public_ipv4_list = [
    for control_plane in hcloud_server.control_plane : control_plane.ipv4_address
  ]
}

