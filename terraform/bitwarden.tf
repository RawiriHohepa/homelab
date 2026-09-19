resource "bitwarden-secrets_secret" "foo" {
  key = "foo"
  value = data.sops_file.secrets.data["secrets.foo"]
  project_id = var.bitwarden_project_id
  note = "The secret value was provided via terraform configuration."
}

# # Generate a new value
# resource "bitwarden-secrets_secret" "db_admin_password" {
#   key         = "db_admin_password"
#   project_id  = var.bitwarden_project_id
#   length      = 32
#   special     = true
#   min_special = 5
# }
