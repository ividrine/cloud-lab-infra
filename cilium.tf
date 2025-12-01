data "helm_template" "cilium" {
  name         = "cilium"
  namespace    = "kube-system"
  chart        = "cilium"
  repository   = "https://helm.cilium.io/"
  version      = var.cilium_version
  kube_version = var.kubernetes_version

  values = [
    yamlencode({
      ipam = {
        mode = "kubernetes"
      }
      routingMode           = "native"
      ipv4NativeRoutingCIDR = var.pod_ipv4_cidr
      k8s = {
        requireIPv4PodCIDR = true
      }
      k8sServiceHost       = local.kube_prism_host
      k8sServicePort       = local.kube_prism_port
      kubeProxyReplacement = true
      securityContext = {
        capabilities = {
          ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
          cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
        }
      }
      gatewayAPI = {
        enabled = true
      },
      operator = {
        nodeSelector = { "node-role.kubernetes.io/control-plane" : "" }
        replicas     = var.control_plane.count > 1 ? 2 : 1
      }
      socketLB = {
        hostNamespaceOnly = true
      }
      loadBalancer = {
        acceleration = "best-effort"
      }
    })
  ]
}

locals {
  cilium_manifest = {
    name     = "cilium"
    contents = data.helm_template.cilium.manifest
  }
}