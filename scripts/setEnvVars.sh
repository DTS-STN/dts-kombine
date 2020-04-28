#!/bin/bash
echo Fetching subscription ID
export TF_VAR_SUBSCRIPTION_ID=`az account show --subscription "MTS" --query 'id' --out tsv`
echo Done.
echo Fetching service principal client id...
az account set --subscription=$TF_VAR_SUBSCRIPTION_ID
export TF_VAR_CLIENT_ID=$(az keyvault secret show --name dts-terraform-sp-id --vault-name MtsSecrets --query value -otsv)
export TF_VAR_CLIENT_SECRET=$(az keyvault secret show --name dts-terraform-sp-pass --vault-name MtsSecrets --query value -otsv)

echo Done.
echo Fetching tenant ID
export TF_VAR_TENANT_ID=`az account show --subscription "MTS" --query 'tenantId' --out tsv`
echo Done.

echo Fetching Client Secrets...
export TF_VAR_K8_CLUSTER_SP_ID=$(az keyvault secret show --name EED-K8-CLUSTER-SP-ID --vault-name MtsSecrets --query value -otsv)
export TF_VAR_K8_CLUSTER_SP_PASS=$(az keyvault secret show --name EED-K8-CLUSTER-SP-PASS --vault-name MtsSecrets --query value -otsv)
export TF_VAR_SSH_PUB=$(az keyvault secret show --name EED-SSH-PUB --vault-name MtsSecrets --query value -otsv)
echo done...

echo Fetching required secrets from Key Vault...
export TF_VAR_KOMBINE_TLS_CERT=`az keyvault secret show --name kombine-tls-cert --vault-name kombine-keyvault-Sandbox --query value -otsv`
export TF_VAR_KOMBINE_TLS_KEY=`az keyvault secret show --name kombine-tls-key --vault-name kombine-keyvault-Sandbox --query value -otsv`
echo done...
