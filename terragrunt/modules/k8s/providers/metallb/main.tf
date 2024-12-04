terraform {
  required_version = ">= 1.5"
}

locals {
  ca_certificate     = base64decode(var.kubeconfig.ca_certificate)
  client_certificate = base64decode(var.kubeconfig.client_certificate)
  client_key         = base64decode(var.kubeconfig.client_key)
  ip_address_pool    = data.infisical_secrets.secrets.secrets["METALLB_IPADDRESSPOOL_DEFAULT"].value
  metallb_namespace  = var.metallb_namespace
}

provider "kubernetes" {
  host                   = var.kubeconfig.host
  cluster_ca_certificate = local.ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}


resource "kubernetes_manifest" "ipaddresspool_default" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "ipaddrpool-default"
      namespace = local.metallb_namespace
    }
    spec = {
      addresses = [
        local.ip_address_pool
      ]
    }
  }
  depends_on = [
    local.metallb_namespace
  ]
}

resource "kubernetes_manifest" "l2advertisement_default" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "l2advertisement-default"
      namespace = local.metallb_namespace
    }
    spec = {
      ipAddressPools : [
        "ipaddrpool-default"
      ]
    }
  }
  depends_on = [
    local.metallb_namespace,
    kubernetes_manifest.ipaddresspool_default
  ]
}
