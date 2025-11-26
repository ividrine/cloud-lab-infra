# Secrets 

hcloud_token      = "example-hcloud-token"
tailscale_authkey = "example-tailscale-authkey"

# Machine

control_plane = { location = "fsn1", server_type = "cx23", count = 1 }
worker = { location = "fsn1", server_type = "cx23", count = 2 }

# Network
network_ipv4_cidr = ""
node_subnet_zone = ""
node_subnet_ipv4_cidr = ""
pod_ipv4_cidr = ""
service_ipv4_cidr = ""