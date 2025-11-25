variable "talos_version" {
  type    = string
  default = "v1.11.5"
}

variable "server_arch" {
  type    = string
  default = "amd64"
}

variable "server_type" {
  type    = string
  default = "cx22"
}

variable "server_location" {
  type    = string
  default = "fsn1"
}

variable "schematic_id" {
  type = string
  default = "4a0d65c669d46663f377e7161e50cfd570c401f26fd9e7bda34a0216b6f1922b"
  description = "schematic id for hetzner cloud talos image with tailscale system extension"
}



