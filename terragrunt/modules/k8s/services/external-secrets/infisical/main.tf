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


resource "helm_release" "external-secrets" {
  name        = "external-secrets"
  namespace   = "external-secrets"
  create_namespace = true
  repository  = "https://charts.external-secrets.io"
  chart       = "external-secrets"
}

resource "kubernetes_secret" "credentials" {
  metadata {
    name = "infisical-credentials"
    namespace = "external-secrets"
  }
  data = {
    clientId = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_CLIENT_ID"].value
    clientSecret = data.infisical_secrets.secrets.secrets["EXTERNALSECRETS_INFISICAL_CLIENT_SECRET"].value
  }
  type = "generic"
}

resource "kubernetes_manifest" "secretstore" {
  depends_on = [helm_release.external-secrets]
  manifest = yamldecode(file("./secretstore.yaml"))
}