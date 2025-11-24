data "hcloud_image" "x86" {
  with_selector = "os=talos"
  with_architecture = "x86"
  most_recent = true
}

resource "hcloud_server" "control_plane" {
  name = "${var.cluster_name}-control-plane"
  image = data.hcloud_image.x86.id
  server_type = var.server_type
  location = var.server_location
  firewall_ids = [hcloud_firewall.firewall.id]
  user_data = data.talos_machine_configuration.control_plane.machine_configuration

  network {
    network_id = hcloud_network.private_network.id
    ip = var.control_plane_internal_ip
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image
    ]
  }

  depends_on = [
    hcloud_network_subnet.private_network_subnet,
    data.talos_machine_configuration.control_plane
  ]
}

resource "hcloud_server" "worker" {
  count = var.worker_count
  name = "${var.cluster_name}-worker-${count.index}"
  image = data.hcloud_image.x86.id
  server_type = var.server_type
  location = var.server_location
  firewall_ids = [hcloud_firewall.firewall.id]
  user_data = data.talos_machine_configuration.worker.machine_configuration

  network {
    network_id = hcloud_network.private_network.id
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image
    ]
  }

  depends_on = [
    hcloud_network_subnet.private_network_subnet,
    hcloud_server.control_plane,
    data.talos_machine_configuration.worker
  ]
}