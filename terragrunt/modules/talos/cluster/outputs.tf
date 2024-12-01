output "talosconfig" {
  value     = data.talos_client_configuration.cluster.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.cluster.kubernetes_client_configuration
  sensitive = true
}

# terragrunt output -raw kubeconfig_raw > ~/.kube/config
output "kubeconfig_raw" {
  value     = talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive = true
}