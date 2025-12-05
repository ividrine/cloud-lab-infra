
locals {
  operator_tag = "tag:k8s-operator"
  service_tag  = "tag:k8s-service"
  admin_group  = "autogroup:admin"
}

# Creates Tailscale ACL needed to run the Tailscale operator as well as 
# connect to the Kubernetes API server from devices in the tailnet.

resource "tailscale_acl" "this" {
  overwrite_existing_content = true
  reset_acl_on_destroy       = true
  acl = jsonencode({

    // Define the tags / tag owners
    "tagOwners" : {
      "${local.operator_tag}" : [],
      "${local.service_tag}" : ["${local.operator_tag}"]
    },

    // Define auto approvers for tags
    "autoApprovers" : {
      "services" : {
        "${local.service_tag}" : [local.service_tag]
      }
    },

    // Define grants that govern access for users, groups, autogroups, tags,
    // Tailscale IP addresses, and subnet ranges.
    "grants" : [
      {
        "src" : [local.admin_group],
        "dst" : [local.operator_tag],
        "app" : {
          "tailscale.com/cap/kubernetes" : [{
            "impersonate" : {
              "groups" : ["system:masters"],
            },
          }],
        },
      },
      {
        "src" : [local.admin_group],
        "dst" : [local.operator_tag],
        "ip" : ["tcp:80", "tcp:443"]
      }
    ],
    "ssh" : [
      // Allow all users to SSH into their own devices in check mode.
      // Comment this section out if you want to define specific restrictions.
      {
        "action" : "check",
        "src" : ["autogroup:member"],
        "dst" : ["autogroup:self"],
        "users" : ["autogroup:nonroot", "root"],
      },
    ]
  })
}

# Create OAuth client for Tailscale operator 

resource "tailscale_oauth_client" "operator" {
  description = "Client used by Tailscale operator"
  scopes      = ["devices:core", "auth_keys"]
  tags        = [local.operator_tag]

  depends_on = [tailscale_acl.this]
}

# Generate manifest for Tailscale operator

data "helm_template" "tailscale_operator" {
  name         = "tailscale"
  repository   = "https://pkgs.tailscale.com/helmcharts"
  chart        = "tailscale-operator"
  version      = var.tailscale_operator_version
  kube_version = var.kubernetes_version
  namespace    = "tailscale"

  values = [
    yamlencode({
      oauth = {
        clientId     = "${tailscale_oauth_client.operator.id}"
        clientSecret = "${tailscale_oauth_client.operator.key}"
      }

      apiServerProxyConfig = {
        mode               = "true"
        allowImpersonation = true
      }
    })
  ]
}

locals {

  tailscale_namespace = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "tailscale"
    }
  })

  tailscale_manifest = {
    name     = "tailscale-manifest"
    contents = <<-EOF
      ${local.tailscale_namespace}
      ---
      ${data.helm_template.tailscale_operator.manifest}
    EOF
  }

}