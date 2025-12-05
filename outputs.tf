output "kubeconfig" {
  value     = local.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = local.talosconfig
  sensitive = true
}

output "talos_client_configuration" {
  value     = data.talos_client_configuration.this
  sensitive = true
}

output "talos_machine_configurations_control_plane" {
  value     = data.talos_machine_configuration.control_plane
  sensitive = true
}

output "talos_machine_configurations_worker" {
  value     = data.talos_machine_configuration.worker
  sensitive = true
}

output "control_plane_private_ipv4_list" {
  value = local.control_plane_private_ipv4_list
}

output "control_plane_public_ipv4_list" {
  value = local.control_plane_public_ipv4_list
}

output "worker_private_ipv4_list" {
  value = local.worker_private_ipv4_list
}

output "worker_public_ipv4_list" {
  value = local.worker_public_ipv4_list
}
