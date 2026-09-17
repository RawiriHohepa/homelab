variable "environment" {
    description = "Environment (currently only production)"
    type = string
}

variable "bitwarden_org_id" {
    description = "Bitwarden Secrets Manager Organization ID"
    type = string
}

variable "bitwarden_project_id" {
    description = "Bitwarden Secrets Manager Project ID"
    type = string
}
