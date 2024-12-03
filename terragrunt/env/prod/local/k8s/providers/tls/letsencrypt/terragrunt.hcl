include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_homelab" {
  config_path = "../../../talos/homelab"
}

dependency "service_certmanager" {
  config_path = "../../../services/cert-manager"
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//k8s/providers/tls/letsencrypt"
}

inputs = {
  kubeconfig = dependency.talos_homelab.outputs.kubeconfig
  certmanager_namespace = dependency.service_certmanager.outputs.namespace
}