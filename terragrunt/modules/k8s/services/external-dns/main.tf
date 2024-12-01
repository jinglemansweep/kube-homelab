terraform {
  required_version = ">= 1.5"
}

locals {
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
    name = "external-dns"
  }
}

resource "helm_release" "this" {
  name        = "external-dns"
  namespace   = "external-dns"
  repository  = "https://kubernetes-sigs.github.io/external-dns/"
  chart       = "external-dns"
  values = [<<EOT
provider: 
  name: cloudflare
env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        name: cloudflare-api-token-secret
        key: api-token
EOT
  ]
  depends_on = [ 
    kubernetes_namespace.this,
    kubernetes_manifest.infisical_cloudflare_api_token
  ]
}

resource "kubernetes_manifest" "infisical_cloudflare_api_token" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "infisical-cloudflare-api-token"
      namespace = "external-dns"
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "infisical"
      }
      target = {
        name = "cloudflare-api-token-secret"
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
  depends_on = [ 
    kubernetes_namespace.this 
  ]
}
