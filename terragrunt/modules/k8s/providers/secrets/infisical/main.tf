terraform {
  required_version = ">= 1.5"
}

locals {
  ca_certificate            = base64decode(var.kubeconfig.ca_certificate)
  client_certificate        = base64decode(var.kubeconfig.client_certificate)
  client_key                = base64decode(var.kubeconfig.client_key)
  externalsecrets_namespace = var.externalsecrets_namespace
}

provider "kubernetes" {
  host                   = var.kubeconfig.host
  cluster_ca_certificate = local.ca_certificate
  client_certificate     = local.client_certificate
  client_key             = local.client_key
}

# Create a Kubernetes Secret with the Infisical credentials used by External-Secrets with values from the
# deployment Infisical secrets store

resource "kubernetes_secret" "credentials_infisical" {
  metadata {
    name      = "credentials-infisical"
    namespace = local.externalsecrets_namespace
  }
  data = {
    clientId     = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_CLIENT_ID"].value
    clientSecret = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_CLIENT_SECRET"].value
  }
  type = "generic"
  depends_on = [
    local.externalsecrets_namespace
  ]
}

# Create a Kubernetes External-Secrets ClusterSecretStore with the Infisical provider

resource "kubernetes_manifest" "secretsmanager_clustersecretstore_infisical" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "clustersecretstore-infisical"
    }
    spec = {
      provider = {
        infisical = {
          auth = {
            universalAuthCredentials = {
              clientId = {
                key       = "clientId"
                namespace = local.externalsecrets_namespace
                name      = kubernetes_secret.credentials_infisical.metadata[0].name
              }
              clientSecret = {
                key       = "clientSecret"
                namespace = local.externalsecrets_namespace
                name      = kubernetes_secret.credentials_infisical.metadata[0].name
              }
            }
          }
          secretsScope = {
            projectSlug     = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_PROJECT_SLUG"].value
            environmentSlug = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_ENVIRONMENT_SLUG"].value
          }
          hostAPI = "https://app.infisical.com"
        }
      }
    }
  }
  depends_on = [
    local.externalsecrets_namespace
  ]
}

