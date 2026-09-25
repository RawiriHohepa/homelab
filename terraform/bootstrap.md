# First-time setup
- TODO
- Generate a SOPS secrets file using age - [tutorial](https://dev.to/hkhelil/secure-secret-management-with-sops-in-terraform-terragrunt-231a)

# Creating a new environment
- Create a new `terraform/sops/secrets.enc.{env}.json` file - you can follow an existing file to match the required keys
- Create a new `terraform/environment/{env}.tfvars` file with `environment = "test"`
- Create a [Cloudflare R2 bucket](https://www.cloudflare.com/products/r2/) bucket
- Create a new `terraform/environment/{env}.tfbackend` file with `bucket = "{bucket-name}"`
- Create an Account API token at `https://dash.cloudflare.com/{account-id}/r2/api-tokens` with `Object Read & Write` permission, scoped to the newly created bucket
    - Add `cloudflare-backend.account-id`, `cloudflare-backend.access-key`, and `cloudflare-backend.secret-key` to the SOPS file. Save `Token value` somewhere secure (we aren't using it here)
- Create [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) project `homelab-production`
    - Find `bitwarden_org_id` and `bitwarden_project_id` from the URL (`https://vault.bitwarden.com/#/sm/{bitwarden_org_id}/projects/{bitwarden_project_id}/secrets`) and add them to `terraform/environment/{env}.tfvars`
- Create a machine account
    - Assign to the project with Read & Write access
- Create an Access Token in the machine account
    - Add `bitwarden-access-token` to the SOPS file
- Populate the remaining SOPS values
- Ensure the correct k8s cluster is the current context with `kubectl config current-context`
    - You can run `kubectl config use-context {context}` to change the current context
- Run `terraform/runTerraform.sh plan {env}`
- Run `terraform/runTerraform.sh apply {env}`
