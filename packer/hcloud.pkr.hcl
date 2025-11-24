
packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1"
    }
  }
}

locals {
  image = "https://factory.talos.dev/image/4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b/${var.talos_version}/hcloud-amd64.raw.xz"
}

source "hcloud" "talos" {
  rescue = "linux64"
  image = "debian-11"
  location = "fsn1"
  server_type = "cx23"
  ssh_username = "root"
  snapshot_name = "Talos System Disk / x86 / ${var.talos_version}"
  snapshot_labels = {
    type = "infra",
    os = "talos",
    version = "${var.talos_version}",
    arch = "x86",
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