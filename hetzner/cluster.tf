module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }

  hcloud_token = var.hcloud_token

  source  = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.2.3"

  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key

  cluster_name = var.cluster_name

  create_kubeconfig    = false
  create_kustomization = false

  ingress_controller        = "none"
  automatically_upgrade_os  = false
  automatically_upgrade_k3s = false
  network_region            = "eu-central"
  load_balancer_type        = "lb11"
  load_balancer_location    = var.control_plane_location

  control_plane_nodepools = [
    {
      name        = "${var.cluster_name}-control-plane-${var.control_plane_location}",
      server_type = var.control_plane_server_type,
      location    = var.control_plane_location,
      labels      = [],
      taints      = [],
      count       = 1

      # Enable automatic backups via Hetzner (default: false)
      # backups = true
    }
  ]

  agent_nodepools = [
    {
      name        = "${var.cluster_name}-workloads-${var.workloads_location}",
      server_type = var.workloads_server_type,
      location    = var.workloads_location,
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  autoscaler_nodepools = [
    {
      name        = "${var.cluster_name}-autoscaled-${var.workloads_location}",
      server_type = var.workloads_server_type,
      location    = var.workloads_location,
      min_nodes   = var.workloads_min_nodes,
      max_nodes   = var.workloads_max_nodes
    }
  ]
}
