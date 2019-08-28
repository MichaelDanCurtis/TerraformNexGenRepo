#!/usr/bin/env bash
export ARM_SUBSCRIPTION_ID=$(az account show --query="id" -o tsv)
export ARM_CLIENT_ID="${servicePrincipalId}"
export ARM_CLIENT_SECRET="${servicePrincipalKey}"
export ARM_TENANT_ID=$(az account show --query="tenantId" -o tsv)
export ARM_ACCESS_KEY=$(az storage account keys list -n ${ARM_STORAGE_ACCOUNT_NAME} --query="[0].value" -o tsv)
terraform init -backend-config="storage_account_name=$ARM_STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$ARM_STORAGE_CONTAINER" \
    -backend-config="key=$ARM_STORAGE_KEY"
terraform plan -out=NGBuild.tfplan

addSpnToEnvironment: true