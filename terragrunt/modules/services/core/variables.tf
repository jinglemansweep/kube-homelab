variable "host" {
  description = "K8S Endpoint Hostname"
  type = string
}

variable "client_certificate" {
  description = "K8S Client Certificate"
  type = string
}

variable "client_key" {
  description = "K8S Client Key"
  type = string
}

variable "ca_certificate" {
  description = "K8S Cluster CA Certificate"
  type = string
}