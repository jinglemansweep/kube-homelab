include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_homelab" {
  config_path = "../../talos/homelab"
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//k8s/services/external-dns"
}

inputs = {
  kubeconfig = dependency.talos_homelab.outputs.kubeconfig
}