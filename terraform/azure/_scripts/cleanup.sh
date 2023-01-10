#!/bin/bash

RESOURCE_GROUP_NAME=${1}-tfstate
RESOURCE_LOCATION=centralus
STORAGE_ACCOUNT_NAME=${1}storage
CONTAINER_NAME=${1}tfstate

echo "Clean up resources storage account ${STORAGE_ACCOUNT_NAME} within group ${RESOURCE_GROUP_NAME}"

STORAGE_SEARCH=$(az storage account check-name --name $STORAGE_ACCOUNT_NAME)

echo "STORAGE_SEARCH ${STORAGE_SEARCH}"

nameAvailable=$( jq -r  '.nameAvailable' <<< "${STORAGE_SEARCH}" )

echo "Storage account name is available ${nameAvailable}"

if !$nameAvailable
then
  echo "Delete storage account --name $STORAGE_ACCOUNT_NAME"
  az storage account delete --name $STORAGE_ACCOUNT_NAME --yes

  echo "Delete resource group ${RESOURCE_GROUP_NAME}"
  az group delete --name $RESOURCE_GROUP_NAME --yes
else
  echo "No Storage account was deleted"
fi


