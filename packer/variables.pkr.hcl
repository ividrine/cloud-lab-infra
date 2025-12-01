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
  default = "cx23"
}

variable "server_location" {
  type    = string
  default = "fsn1"
}

variable "schematic_id" {
  type = string
  default = "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
  description = "schematic id for hetzner cloud talos image with no system extensions"
}



