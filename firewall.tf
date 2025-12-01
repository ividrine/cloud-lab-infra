data "http" "source_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  source_ip = "${chomp(data.http.source_ip.response_body)}/32"
}

resource "hcloud_firewall" "this" {
  name = var.cluster_name

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "50000"
    source_ips = [local.source_ip]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = [local.source_ip]
  }
}