#!/bin/bash

RESOURCE_GROUP_NAME=${1}-tfstate
RESOURCE_LOCATION=centralus
STORAGE_ACCOUNT_NAME=${1}storage
CONTAINER_NAME=${1}tfstate

echo "Setting up storage account ${STORAGE_ACCOUNT_NAME} within group ${RESOURCE_GROUP_NAME}"

STORAGE_SEARCH=$(az storage account check-name --name $STORAGE_ACCOUNT_NAME)

echo "STORAGE_SEARCH ${STORAGE_SEARCH}"

nameAvailable=$( jq -r  '.nameAvailable' <<< "${STORAGE_SEARCH}" )

echo "Storage account name is available ${nameAvailable}"

if $nameAvailable
then
  echo "Create resource group ${RESOURCE_GROUP_NAME} in location ${RESOURCE_LOCATION}"
  az group create --name $RESOURCE_GROUP_NAME --location $RESOURCE_LOCATION

  echo "Create storage account ${STORAGE_ACCOUNT_NAME} within resource group ${RESOURCE_GROUP_NAME} --sku Standard_LRS --encryption-services blob "
  az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

  echo "Create blob container ${CONTAINER_NAME} on storage account ${STORAGE_ACCOUNT_NAME}"
  az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
  echo "Storage account created successfully"
else
  echo "No Storage account was created"
fi


