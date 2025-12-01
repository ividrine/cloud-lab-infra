# Health check

data "http" "kube_api_health" {
  url      = "${local.kube_api_url_external}/version"
  insecure = true

  retry {
    attempts     = 60
    min_delay_ms = 5000
    max_delay_ms = 5000
  }

  depends_on = [talos_machine_bootstrap.this]
}