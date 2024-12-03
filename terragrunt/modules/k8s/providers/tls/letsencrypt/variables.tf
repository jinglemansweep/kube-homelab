variable "kubeconfig" {
  description = "KubeConfig"
  type = object({
    host = string
    ca_certificate = string
    client_certificate = string
    client_key = string
  })
}

variable "certmanager_namespace" {
  description = "Namespace for cert-manager"
  type = string
}
