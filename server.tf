data "hcloud_image" "x86" {
  with_selector     = "os=talos"
  with_architecture = "x86"
  most_recent       = true
}

locals {

  control_planes = [
    for i in range(var.control_plane.count) : {
      index       = i
      name        = "${var.cluster_name}-control-plane-${i}"
      server_type = var.control_plane.server_type
      location    = var.control_plane.location
    }
  ]

  workers = [
    for i in range(var.worker.count) : {
      index       = i
      name        = "${var.cluster_name}-worker-${i}"
      server_type = var.worker.server_type
      location    = var.worker.location
    }
  ]
}

resource "hcloud_server" "control_plane" {
  for_each     = { for control_plane in local.control_planes : control_plane.name => control_plane }
  name         = each.value.name
  image        = data.hcloud_image.x86.id
  server_type  = each.value.server_type
  location     = each.value.location
  firewall_ids = [hcloud_firewall.firewall.id]
  user_data    = data.talos_machine_configuration.control_plane[each.value.name].machine_configuration

  network {
    network_id = hcloud_network.cloud_network.id
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image
    ]
  }

  depends_on = [
    hcloud_network_subnet.node_subnet,
    data.talos_machine_configuration.control_plane
  ]
}

resource "hcloud_server" "worker" {
  for_each     = { for worker in local.workers : worker.name => worker }
  name         = each.value.name
  image        = data.hcloud_image.x86.id
  server_type  = each.value.server_type
  location     = each.value.location
  firewall_ids = [hcloud_firewall.firewall.id]
  user_data    = data.talos_machine_configuration.worker[each.value.name].machine_configuration

  network {
    network_id = hcloud_network.cloud_network.id
  }

  lifecycle {
    ignore_changes = [
      user_data,
      image
    ]
  }

  depends_on = [
    hcloud_network_subnet.node_subnet,
    data.talos_machine_configuration.worker
  ]
}