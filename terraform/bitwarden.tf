resource "bitwarden-secrets_secret" "foo" {
  key = "foo"
  value = data.sops_file.secrets.data["secrets.foo"]
  project_id = var.bitwarden_project_id
  note = "The secret value was provided via terraform configuration."
}

resource "bitwarden-secrets_secret" "cloudflare_access_token_dns" {
  key = "cloudflare-access-token-dns"
  value = data.sops_file.secrets.data["secrets.cloudflare-access-token-dns"]
  project_id = var.bitwarden_project_id
  note = "Cloudflare access token with Zone Read and DNS Write permissions."
}

# https://tailscale.com/docs/kubernetes-operator/quickstart#create-oauth-credentials-and-configure-secrets
resource "bitwarden-secrets_secret" "tailscale_client_id" {
  key = "tailscale-client-id"
  value = data.sops_file.secrets.data["secrets.tailscale-client-id"]
  project_id = var.bitwarden_project_id
}

resource "bitwarden-secrets_secret" "tailscale_client_secret" {
  key = "tailscale-client-secret"
  value = data.sops_file.secrets.data["secrets.tailscale-client-secret"]
  project_id = var.bitwarden_project_id
}

# # Generate a new value
# resource "bitwarden-secrets_secret" "db_admin_password" {
#   key         = "db_admin_password"
#   project_id  = var.bitwarden_project_id
#   length      = 32
#   special     = true
#   min_special = 5
# }
