# https://docs.siderolabs.com/talos/v1.11/platform-specific-installations/cloud-platforms/hetzner

packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1"
    }
  }
}

locals {
  image = "https://factory.talos.dev/image/${var.schematic_id}/${var.talos_version}/hcloud-${var.server_arch}.raw.xz"
}

source "hcloud" "talos" {
  rescue = "linux64"
  image = "debian-11"
  location = var.server_location
  server_type = var.server_type
  ssh_username = "root"
  snapshot_name = "Talos System Disk / ${var.server_arch} / ${var.talos_version}"
  snapshot_labels = {
    type = "infra",
    os = "talos",
    version = var.talos_version,
    arch = var.server_arch,
  }
}

build {
  sources = ["source.hcloud.talos"]
  provisioner "shell" {
    inline = [
      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}