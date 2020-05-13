#!/bin/bash
RESOURCE_GROUP_NAME=EsDCKombineRG
STORAGE_ACCOUNT_NAME=dtskombinestorage
CONTAINER_NAME=kombinetfstate
SUBSCRIPTION_ID=`az account show --subscription "MTS" --query 'id' --out tsv`

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location canadacentral

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
export ACCOUNT_KEY=`az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv`
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

dirs -c

cd ..

pushd terraform

terraform import azurerm_resource_group.main /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME

terraform import azurerm_storage_account.$STORAGE_ACCOUNT_NAME /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME

terraform import azurerm_storage_container.$CONTAINER_NAME https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME
terraform init

terraform apply
