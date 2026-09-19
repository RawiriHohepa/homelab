#!/usr/bin/env bash

# usage: ./runTerraform.sh [plan|apply] [production]

set -euo pipefail

TERRAFORM_OPERATION="${1:-plan}"
ENVIRONMENT="${2:-production}"

read CLOUDFLARE_ACCOUNT_ID CLOUDFLARE_ACCESS_KEY CLOUDFLARE_SECRET_KEY < <(echo $(sops decrypt sops/secrets.enc.$ENVIRONMENT.json | jq -r '."cloudflare-backend"."account-id", ."cloudflare-backend"."access-key", ."cloudflare-backend"."secret-key"'))
export AWS_ENDPOINT_URL_S3=https://$CLOUDFLARE_ACCOUNT_ID.r2.cloudflarestorage.com
export AWS_ACCESS_KEY_ID=$CLOUDFLARE_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$CLOUDFLARE_SECRET_KEY

terraform init \
    -backend-config="environment/$ENVIRONMENT.tfbackend" \
    -reconfigure

terraform $TERRAFORM_OPERATION \
    -var-file="environment/$ENVIRONMENT.tfvars"
