terraform {
    required_version = "~> 1.16.3"
    required_providers {
        sops = {
            source = "carlpett/sops"
            version = "~> 1.4.1"
        }
        bitwarden-secrets = {
            source = "registry.terraform.io/bitwarden/bitwarden-secrets"
            version = "~> 1.0.1"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 3.2.1"
        }
    }
}

provider "sops" {}

# Must be data instead of ephemeral - bitwarden secrets are not write-only and must be persisted in state
# TF state is stored remotely in Cloudflare R2 so plaintext secrets is acceptable
data "sops_file" "secrets" {
    source_file = "sops/secrets.enc.${var.environment}.json"
}

provider "bitwarden-secrets" {
    api_url = "https://api.bitwarden.com"
    identity_url = "https://identity.bitwarden.com"
    organization_id = var.bitwarden_org_id
    access_token = data.sops_file.secrets.data["bitwarden-access-token"]
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

terraform {
    backend "s3" {
        key = "terraform.tfstate"
        use_lockfile = true

        # uses AWS_ACCESS_KEY_ID env variable
        access_key = ""
        # uses AWS_SECRET_ACCESS_KEY env variable
        secret_key = ""
        # uses AWS_ENDPOINT_URL_S3 env variable
        endpoints = {
            # s3 = ""
        }

        # Compatibility settings for Cloudflare R2
        region = "us-east-1"
        skip_credentials_validation = true
        skip_region_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        skip_s3_checksum = true
    }
}
