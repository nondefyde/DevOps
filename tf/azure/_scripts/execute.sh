#! /bin/bash

echo "Run Deployment"

echo "Project     : ${1}"
echo "Image       : ${2}"
echo "App Secret  : ${3}"
echo "Vm Name     : ${4}"
echo "Vm Count    : ${5}"

RESOURCE_GROUP_NAME=${1}-group
IMAGE=${2}
APP_SECRET=${3}
VM_NAME=${4}
VM_COUNT=${5}

for i in $(seq 1 ${5}); do

  echo "Cleanup previous deployment"
  az vm run-command invoke \
    --resource-group ${RESOURCE_GROUP_NAME} \
    --name ${1}-${4}-vm-$i \
    --command-id RunShellScript \
    --scripts '
         sudo mkdir vm
         sudo touch vm/.env
         DECODED=$(echo $1 | base64 --decode > vm/.env)
      ' \
    --parameters ${APP_SECRET}

  echo "Run Command on VM ${1}-${4}-vm-$i"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${1}-${4}-vm-$i \
    --resource-group ${RESOURCE_GROUP_NAME} \
    --scripts "curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s $1 $2 $3"
done


