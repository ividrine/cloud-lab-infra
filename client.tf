# Retrive talos client config

data "talos_client_configuration" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.cluster_name
  endpoints            = local.control_plane_public_ipv4_list
  nodes                = [local.talos_primary_node_private_ipv4]
}

# Retrieve kubeconfig

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.talos_primary_endpoint

  depends_on = [talos_machine_configuration_apply.control_plane]
}

locals {

  kubeconfig = replace(
    talos_cluster_kubeconfig.this.kubeconfig_raw,
    "/(\\s+server:).*/",
    "$1 ${local.kube_api_url_external}"
  )

  talosconfig = data.talos_client_configuration.this.talos_config

  # Used for other providers
  kubeconfig_data = {
    name = var.cluster_name
    host = local.kube_api_url_external
    ca   = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
    cert = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    key  = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  }

  talosconfig_data = {
    name      = data.talos_client_configuration.this.cluster_name
    endpoints = data.talos_client_configuration.this.endpoints
    ca        = base64decode(data.talos_client_configuration.this.client_configuration.ca_certificate)
    cert      = base64decode(data.talos_client_configuration.this.client_configuration.client_certificate)
    key       = base64decode(data.talos_client_configuration.this.client_configuration.client_key)
  }
}