terraform {
  required_version = ">= 1.5"
}

locals {
  namespace          = "metallb-system"
  ca_certificate     = base64decode(var.kubeconfig.ca_certificate)
  client_certificate = base64decode(var.kubeconfig.client_certificate)
  client_key         = base64decode(var.kubeconfig.client_key)
  ip_address_pool    = data.infisical_secrets.secrets.secrets["METALLB_IPADDRESSPOOL_DEFAULT"].value
}

provider "kubernetes" {
  host                   = var.kubeconfig.host
  cluster_ca_certificate = local.ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}

provider "helm" {
  kubernetes {
    host                   = var.kubeconfig.host
    cluster_ca_certificate = local.ca_certificate
    client_certificate     = local.client_certificate
    client_key             = local.client_key
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "this" {
  name       = "metallb"
  namespace  = local.namespace
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  wait       = false
  depends_on = [
    kubernetes_namespace.this
  ]
}
