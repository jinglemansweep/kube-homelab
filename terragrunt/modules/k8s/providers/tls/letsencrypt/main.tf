terraform {
  required_version = ">= 1.5"
}

locals {
  ca_certificate            = base64decode(var.kubeconfig.ca_certificate)
  client_certificate        = base64decode(var.kubeconfig.client_certificate)
  client_key                = base64decode(var.kubeconfig.client_key)
  certmanager_namespace = var.certmanager_namespace
  email = data.infisical_secrets.secrets.secrets["CERTMANAGER_LETSENCRYPT_EMAIL"].value
  issuers = {
    prod = {
      name = "letsencrypt-prod"
      server = "https://acme-v02.api.letsencrypt.org/directory"
    },
    stg = {
      name = "letsencrypt-stg"
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    }
  }
}

provider "kubernetes" {
  host                   = var.kubeconfig.host
  cluster_ca_certificate = local.ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}


resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  for_each = local.issuers
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = each.value.name
    }
    spec = {
      acme = {
        server = each.value.server
        email  = local.email
        privateKeySecretRef = {
          name = each.value.name
        }
        solvers = [
          {
            dns01 = {
              cloudflare= {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token"
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
    local.certmanager_namespace
  ]
}
