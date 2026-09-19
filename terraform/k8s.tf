resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    labels = {
      name = "external-secrets"
    }

    name = "external-secrets"
  }
}

resource "kubernetes_secret_v1" "bitwarden_access_token" {
  depends_on = [ kubernetes_namespace_v1.external_secrets ]

  metadata {
    name = "bitwarden-access-token"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
  }

  data = {
    token = data.sops_file.secrets.data["bitwarden_access_token"]
  }

  type = "Opaque"
}
