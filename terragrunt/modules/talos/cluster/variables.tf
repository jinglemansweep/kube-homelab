variable "cluster_name" {
  description = "Cluster Name"
  type = string
}

variable "cluster_endpoint" {
  description = "Cluster Endpoint"
  type = string
}

variable "cluster_nodes" {
  description = "Cluster Node Configuration Map"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "talos1.local" = {
        install_disk = "/dev/vda"
        hostname     = "controlplane1"
      }
    }
    workers = {
      "talos2.local" = {
        install_disk = "/dev/vda"
        hostname     = "worker1"
      },
    }
  }
}

variable "install_image" {
  description = "Talos Install Image"
  type = string
  default = "ghcr.io/talos-systems/talos:latest"
}