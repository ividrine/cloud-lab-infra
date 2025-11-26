# General

variable "cluster_name" {
  type    = string
  default = "cloud-lab"
}

# Local DNS

variable "cluster_domain" {
  type    = string
  default = "kube.cloud-lab.local"
}

# Secrets

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "tailscale_authkey" {
  type      = string
  sensitive = true
}

# Networking

variable "network_ipv4_cidr" {
  type    = string
  default = null
}

variable "node_subnet_zone" {
  type    = string
  default = null
}

variable "node_subnet_ipv4_cidr" {
  type    = string
  default = null
}

variable "pod_ipv4_cidr" {
  type    = string
  default = null
}

variable "service_ipv4_cidr" {
  type    = string
  default = null
}

# Servers

variable "control_plane" {
  type = object({
    location    = string
    server_type = string
    count       = number
  })
}

variable "worker" {
  type = object({
    location    = string
    server_type = string
    count       = number
  })
}
