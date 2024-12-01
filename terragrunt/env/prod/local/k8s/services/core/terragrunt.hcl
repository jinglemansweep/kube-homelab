include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_homelab" {
  config_path = "../../talos/homelab"
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//services/core"
}

inputs = {
  host = dependency.talos_homelab.outputs.kubeconfig.host
  client_certificate = dependency.talos_homelab.outputs.kubeconfig.client_certificate
  client_key = dependency.talos_homelab.outputs.kubeconfig.client_key
  ca_certificate = dependency.talos_homelab.outputs.kubeconfig.ca_certificate
}