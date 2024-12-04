include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_homelab" {
  config_path = "../../../talos/homelab"
}

dependency "service_metallb" {
  config_path = "../../../services/metallb"
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//k8s/providers/metallb"
}

inputs = {
  kubeconfig = dependency.talos_homelab.outputs.kubeconfig
  metallb_namespace = dependency.service_metallb.outputs.namespace
}