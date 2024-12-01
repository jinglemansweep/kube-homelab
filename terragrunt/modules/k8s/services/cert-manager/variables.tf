variable "kubeconfig" {
  description = "KubeConfig"
  type = object({
    host = string
    ca_certificate = string
    client_certificate = string
    client_key = string
  })
}
