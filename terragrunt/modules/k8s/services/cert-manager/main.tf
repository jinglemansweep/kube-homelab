terraform {
  required_version = ">= 1.5"
}

locals {
  namespace = "cert-manager"
  ca_certificate     = base64decode(var.kubeconfig.ca_certificate)
  client_certificate = base64decode(var.kubeconfig.client_certificate)
  client_key         = base64decode(var.kubeconfig.client_key)
}

provider "kubernetes" {
  host = var.kubeconfig.host
  cluster_ca_certificate = local.ca_certificate
  client_certificate = local.client_certificate
  client_key = local.client_key
}

provider "helm" {
  kubernetes {
    host = var.kubeconfig.host
    cluster_ca_certificate = local.ca_certificate
    client_certificate = local.client_certificate
    client_key = local.client_key
  }
}


resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "this" {
  name        = "cert-manager"
  namespace   = local.namespace
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  wait = true
  set {
    name  = "crds.enabled"
    value = true
  }
  depends_on = [
    kubernetes_namespace.this
  ]
}


resource "kubernetes_manifest" "externalsecret_cloudflare_api_token" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "cloudflare-api-token"
      namespace = local.namespace
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "clustersecretstore-infisical"
      }
      target = {
        name = "cloudflare-api-token"
      }
      data = [
        {
          secretKey = "api-token"
          remoteRef = {
            key = "CLOUDFLARE_API_TOKEN"
          }
        }
      ]
    }
  }
  depends_on = []
}