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


resource "helm_release" "cert-manager" {
  name        = "cert-manager"
  namespace   = "cert-manager"
  create_namespace = true
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  set {
    name  = "crds.enabled"
    value = true
  }
}

resource "kubernetes_manifest" "infisical-cloudflare-api-token" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "infisical-cloudflare-api-token"
      namespace = "cert-manager"
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "infisical"
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
  depends_on = [ 
    helm_release.cert-manager
  ]
}

locals {
  email = data.infisical_secrets.secrets.secrets["LETSENCRYPT_EMAIL"].value
  issuers = [
    { name = "letsencrypt-stg", server = "https://acme-staging-v02.api.letsencrypt.org/directory" },
    { name = "letsencrypt-prod", server = "https://acme-v02.api.letsencrypt.org/directory" },
  ]
}

resource "kubernetes_manifest" "issuers-letsencrypt" {
  for_each = { for issuer in local.issuers : issuer.name => issuer }
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = each.value.name
    }
    spec = {
      acme = {
        email = local.email,
        server = each.value.server
        privateKeySecretRef = {
          name = "${each.value.name}-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token-secret"
                  key = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [
    kubernetes_manifest.infisical-cloudflare-api-token
  ]
}
