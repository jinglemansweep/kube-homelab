include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terragrunt/modules//k8s/talos/cluster"
}

inputs = {
  cluster_name = "Homelab"
  cluster_endpoint = "https://talos1.adm.ptre.es:6443"
  cluster_nodes = {
    controlplanes = {
      "talos1.adm.ptre.es" = {
        install_disk = "/dev/vda"
        hostname     = "talos1.adm.ptre.es"
      }
    },
    workers = {
      "talos2.adm.ptre.es" = {
        install_disk = "/dev/vda"
        hostname     = "talos2.adm.ptre.es"
      }
    }
  }
  install_image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.3"
}