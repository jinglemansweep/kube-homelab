terraform {
  required_version = ">= 1.5"
}

locals {
  ca_certificate     = base64decode(var.ca_certificate)
  client_certificate = base64decode(var.client_certificate)
  client_key         = base64decode(var.client_key)
}

provider "helm" {
  kubernetes {
    host = var.host
    cluster_ca_certificate = local.ca_certificate
    client_certificate = local.client_certificate
    client_key = local.client_key
  }
}
