variable "kubeconfig" {
  description = "KubeConfig"
  type = object({
    host = string
    ca_certificate = string
    client_certificate = string
    client_key = string
  })
}

variable "externalsecrets_namespace" {
  description = "Namespace for external-secrets"
  type = string
}