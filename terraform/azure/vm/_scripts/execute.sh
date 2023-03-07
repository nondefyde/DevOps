#! /bin/bash

echo "Run Deployment"

echo "Client            : ${1}"
echo "Secret            : ${2}"
echo "Tenant            : ${3}"
echo "Project           : ${4}"
echo "Prefix            : ${5}"
echo "Image             : ${6}"
echo "App Secret        : ${7}"
echo "Vm Name           : ${8}"
echo "Vm Count          : ${9}"
echo "Vm User           : ${10}"
echo "Virtual Host      : ${11}"
echo "Port Host         : ${12}"
echo "Environment       : ${13}"
echo "Container Inst.   : ${14}"


CLIENT=${1}
SECRET=${2}
TENANT=${3}
PROJECT=${4}
RESOURCE_GROUP=${4}-group
PREFIX=${5}
IMAGE=${6}
APP_SECRET=${7}
VM_NAME=${8}
VM_COUNT=${9}
VM_USER=${10}
VIRTUAL_HOST=${11}
PORT=${12}
ENV=${13}
INSTANCE=${14}

PREP_SCRIPT="https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh"

LOGIN_SERVER=$(az acr login -n ${PREFIX}acr --expose-token)
accessToken=$(jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
echo "logged in to server > ${server}"

echo "${PROJECT} ${IMAGE} ${INSTANCE} ${VM_USER} vm-app-"

for i in $(seq 1 ${VM_COUNT}); do
  INDEX=$((i - 1))
  echo "Prepare VM ${PROJECT}-${VM_NAME}-vm-$INDEX"
  echo "curl -s ${PREP_SCRIPT} | bash -s ${PROJECT} ${APP_SECRET} ${IMAGE} ${ENV} ${VIRTUAL_HOST} ${PORT} ${VM_USER}"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${PREFIX}-${VM_NAME}-vm-$INDEX \
    --resource-group ${RESOURCE_GROUP} \
    --scripts "curl -s ${PREP_SCRIPT} | bash -s ${PROJECT} ${APP_SECRET} ${IMAGE} ${ENV} ${VIRTUAL_HOST} ${PORT} ${VM_USER}"

  echo "Login Azure in VM ${PREFIX}-${VM_NAME}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${PREFIX}-${VM_NAME}-vm-$INDEX \
    --resource-group ${RESOURCE_GROUP} \
    --scripts '
         az login --service-principal --username ${1} --password ${2} --tenant ${3}
      ' \
    --parameters ${CLIENT} ${SECRET} ${TENANT}

  echo "Login docker on VM ${PREFIX}-${VM_NAME}-vm-$INDEX"
    az vm run-command invoke \
      --command-id RunShellScript \
      --name ${PREFIX}-${VM_NAME}-vm-$INDEX \
      --resource-group ${RESOURCE_GROUP} \
      --scripts '
        echo "Login docker"
        docker login $1 --username 00000000-0000-0000-0000-000000000000 --password $2
      ' \
      --parameters "${server}" "${accessToken}"

  echo "Deploy Update on VM ${PREFIX}-${VM_NAME}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${PREFIX}-${VM_NAME}-vm-$INDEX \
    --resource-group ${RESOURCE_GROUP} \
    --scripts '
      cd /home/$4/vm
      ls -a
      chmod +x deploy.sh
      ./deploy.sh $1 $2 $3
    ' \
    --parameters "${PROJECT}" "${IMAGE}" "vm-app-" "${VM_USER}"
done