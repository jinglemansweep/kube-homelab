include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_homelab" {
  config_path = "../../../talos/homelab"
}

dependency "service_externalsecrets" {
  config_path = "../../../services/external-secrets"
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//k8s/providers/secrets/infisical"
}

inputs = {
  kubeconfig = dependency.talos_homelab.outputs.kubeconfig
  externalsecrets_namespace = dependency.service_externalsecrets.outputs.namespace
}