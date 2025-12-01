data "helm_template" "hcloud_ccm" {
  name      = "hcloud-cloud-controller-manager"
  namespace = "kube-system"

  repository   = "https://charts.hetzner.cloud"
  chart        = "hcloud-cloud-controller-manager"
  version      = var.hcloud_ccm_version
  kube_version = var.kubernetes_version

  # https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/chart/values.yaml

  values = [
    yamlencode({
      kind         = "DaemonSet"
      nodeSelector = { "node-role.kubernetes.io/control-plane" : "" }
      networking = {
        enabled     = true
        clusterCIDR = var.pod_ipv4_cidr
      }
      env = {
        HCLOUD_LOAD_BALANCERS_ENABLED = { value = "false" }
        HCLOUD_NETWORK_ROUTES_ENABLED = { value = "true" }
      }
    })
  ]
}

locals {

  hcloud_secret_manifest = {
    name = "hcloud-secret"
    contents = yamlencode({
      apiVersion = "v1"
      kind       = "Secret"
      type       = "Opaque"
      metadata = {
        name      = "hcloud"
        namespace = "kube-system"
      }
      data = {
        network = base64encode(local.hcloud_network_id)
        token   = base64encode(var.hcloud_token)
      }
    })
  }

  hcloud_ccm_manifest = {
    name     = "hcloud-ccm"
    contents = data.helm_template.hcloud_ccm.manifest
  }
}