# General

variable "cluster_name" {
  type = string
  default = "dummy.com"
}

variable "datacenter_name" {
  type = string
  default = "fsn1-dc14"
}

# Secrets

variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "tailscale_auth_key" {
  type = string
  sensitive = true
}

# Networking

variable "network_ipv4_cidr" {
  type = string
  default = ""
}

variable "node_ipv4_cidr" {
  type = string
  default = ""
}

variable "pod_ipv4_cidr" {
  type = string
  default = ""
}

variable "service_ipv4_cidr" {
  type = string
  default = ""
}