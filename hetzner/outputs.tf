output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

output "kubeconfig_data" {
  value     = module.kube-hetzner.kubeconfig_data
  sensitive = true
}
