#!/bin/bash
source ./scripts/setEnvVars.sh
echo Setting Environment Specifics
export FQDN=$(az aks show --resource-group DTS-Dev --name DTS-Dev-K8S --query fqdn -otsv | awk -F. '{print $1}')
export BASE_DOMAIN=dts-stn.com
export ADMIN_DOMAIN=dts-stn.com
export CLIENT_BASE_DOMAIN=dts-stn.com
export TRAEFIK_AZURE_CLIENT_ID=$(az keyvault secret show --name EED-TRAEFIK-SP-USER --vault-name MtsSecrets --query value -otsv)
export TRAEFIK_AZURE_CLIENT_SECRET=$(az keyvault secret show --name EED-TRAEFIK-SP-PASS --vault-name MtsSecrets --query value -otsv)
export GRAFANA_ADMIN_PASSWORD=$(az keyvault secret show --name EED-GRAFANA-ADMIN-PASS --vault-name MtsSecrets --query value -otsv)
export KIBANA_ADMIN_PASSWORD=$(az keyvault secret show --name KOMBINE-KIBANA-PASS --vault-name MtsSecrets --query value -otsv)
export GRAYLOG_PASSWORD=$(az keyvault secret show --name EED-GRAYLOG-ADMIN-PASS --vault-name MtsSecrets --query value -otsv)
export SENDGRID_PASSWORD=$(az keyvault secret show --name KOMBINE-SENDGRID-PASS --vault-name MtsSecrets --query value -otsv)
export TRAEFIK_DOMAIN_SUBSCRIPTION_ID=$(az account show --subscription "MTS" --query 'id' --out tsv)
export TF_VAR_KOMBINE_RG_NAME=EsDCKombineRG
export TF_VAR_Kombine_DATA_RG_NAME=EsDCKombineRG_DATA
export TF_VAR_ENVIRONMENT_NAME=covid-dev
export TF_VAR_SECONDARY_ENVIRONMENT_NAME=covid-staging
export TF_VAR_CLASSIFICATION=Unclassified
export TF_VAR_TERRAFORM_ENVIRONMENT_NAME=Sandbox
export TF_VAR_KOMBINE_TLS_CERT=$(az keyvault secret show -n kombine-tls-cert --vault-name kombine-keyvault-Sandbox --query value -otsv)
export TF_VAR_KOMBINE_TLS_KEY=$(az keyvault secret show --name kombine-tls-key --vault-name kombine-keyvault-Sandbox --query value -otsv)
az aks get-credentials --resource-group DTS-Dev --name DTS-Dev-K8S
echo Creating namespaces because Helm3.
./scripts/setup/createNamespaces.sh covid-dev &>/dev/null