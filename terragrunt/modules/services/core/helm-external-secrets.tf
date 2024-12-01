resource "helm_release" "external-secrets" {
  name        = "external-secrets"
  namespace   = "external-secrets"
  create_namespace = true
  repository  = "https://charts.external-secrets.io"
  chart       = "external-secrets"
}