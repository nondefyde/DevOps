#! /bin/bash

echo "Run Deployment"

echo "Client    : ${1}"
echo "Secret    : ${2}"
echo "Renant    : ${3}"

echo "Project     : ${4}"
echo "Image       : ${5}"
echo "App Secret  : ${6}"
echo "Vm Name     : ${7}"
echo "Vm Count    : ${8}"

PROJECT=${4}
RESOURCE_GROUP_NAME=${4}-group
IMAGE=${5}
APP_SECRET=${6}
VM_NAME=${7}
VM_COUNT=${8}

for i in $(seq 1 ${8}); do
  echo "Login Azure in VM ${4}-${7}-vm-$i"
    az vm run-command invoke \
      --command-id RunShellScript \
      --name ${4}-${7}-vm-$i \
      --resource-group ${RESOURCE_GROUP_NAME} \
      --scripts '
           az login --service-principal --username ${1} --password ${2} --tenant ${3}
        ' \
      --parameters ${1} ${2} ${3}

  echo "Run Deploy Command on VM ${4}-${7}-vm-$i"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${4}-${7}-vm-$i \
    --resource-group ${RESOURCE_GROUP_NAME} \
    --scripts '
         curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s ${1} ${2} ${3}
      ' \
    --parameters ${PROJECT} ${IMAGE} ${APP_SECRET}
done


