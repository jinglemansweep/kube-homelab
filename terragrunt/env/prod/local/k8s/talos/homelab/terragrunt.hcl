include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//talos/cluster"
}

inputs = {
  cluster_name = "Homelab"
  cluster_endpoint = "https://talos1.adm.ptre.es:6443"
  cluster_nodes = {
    controlplanes = {
      "talos1.adm.ptre.es" = {
        install_disk = "/dev/vda"
        hostname     = "controlplane1"
      }
    },
    workers = {
      "talos2.adm.ptre.es" = {
        install_disk = "/dev/vda"
        hostname     = "worker1"
      }
    }
  }
  install_image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.3"
}