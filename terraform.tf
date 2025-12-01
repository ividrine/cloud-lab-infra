terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.56.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.24.0"
    }
  }
}