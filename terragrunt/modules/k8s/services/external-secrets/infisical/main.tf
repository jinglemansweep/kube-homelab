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
    name = "external-secrets"
  }
}

resource "helm_release" "this" {
  name        = "external-secrets"
  namespace   = "external-secrets"
  repository  = "https://charts.external-secrets.io"
  chart       = "external-secrets"
  depends_on = [
    kubernetes_namespace.this
  ]
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
  depends_on = [
    kubernetes_namespace.this
  ]
}

resource "kubernetes_manifest" "secretstore" {
  manifest = yamldecode(file("./secretstore.yaml"))
  depends_on = [
    helm_release.this,
    kubernetes_secret.credentials
  ]
}