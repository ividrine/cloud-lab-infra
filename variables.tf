# General

variable "cluster_name" {
  type = string
  default = "cloud-lab"
}

# Secrets

variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "tailscale_authkey" {
  type = string
  sensitive = true
}

variable "github_token" {
  type = string
  sensitive = true
}

# Network

variable "network_ip_range" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_zone" {
  type = string
  default = "eu-central"
}

# Machine

variable "server_type" {
  type = string
  # x86 4gb ram 2vcpu
  default = "cx23"  
}

variable "server_location" {
  type = string
  default = "fsn1"
}

variable "worker_count" {
  type = number
  default = 2
}

variable "control_plane_internal_ip" {
  type = string
  default = "10.0.1.1"
}

