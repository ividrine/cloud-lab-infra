data "http" "gateway_api_standard" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_crd_version}/standard-install.yaml"
}

data "http" "gateway_api_tlsroute" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${var.gateway_api_crd_version}/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
}

locals {
  gateway_api_manifest = {
    name     = "gateway-api-manifest"
    contents = <<-EOF
      ${data.http.gateway_api_standard.response_body}
      ---
      ${data.http.gateway_api_tlsroute.response_body}
    EOF
  }
}