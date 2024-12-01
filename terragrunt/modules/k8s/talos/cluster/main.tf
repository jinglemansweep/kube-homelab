resource "talos_machine_secrets" "cluster" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
}

data "talos_client_configuration" "cluster" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints            = [for k, v in var.cluster_nodes.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = var.cluster_nodes.controlplanes
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/patch-machine.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.cluster_nodes.controlplanes), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
      install_image = var.install_image
    }),
    file("${path.module}/files/patch-cluster-scheduling.yaml"),
    file("${path.module}/files/patch-cluster-proxy.yaml")
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = var.cluster_nodes.workers
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/patch-machine.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-worker-%s", var.cluster_name, index(keys(var.cluster_nodes.workers), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
      install_image = var.install_image
    }),
    file("${path.module}/files/patch-cluster-proxy.yaml")
  ]
}

resource "talos_machine_bootstrap" "cluster" {
  depends_on = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = [for k, v in var.cluster_nodes.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "cluster" {
  depends_on           = [talos_machine_bootstrap.cluster]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = [for k, v in var.cluster_nodes.controlplanes : k][0]
}