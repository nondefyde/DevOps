#! /bin/bash

echo "Run Deployment"

echo "Client            : ${1}"
echo "Secret            : ${2}"
echo "Tenant            : ${3}"
echo "Project           : ${4}"
echo "Image             : ${5}"
echo "App Secret        : ${6}"
echo "Vm Name           : ${7}"
echo "Vm Count          : ${8}"
echo "Vm User           : ${9}"
echo "Virtual Host      : ${10}"
echo "Port Host         : ${11}"
echo "Environment       : ${12}"
echo "Container Inst.   : ${13}"

PROJECT=${4}
IMAGE=${5}
APP_SECRET=${6}
VM_NAME=${7}
VM_COUNT=${8}
VM_USER=${9}
VIRTUAL_HOST=${10}
PORT=${11}
ENV=${12}
INSTANCE=${13}

PREP_SCRIPT="https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh"

LOGIN_SERVER=$(az acr login -n ${PROJECT}acr --expose-token)
accessToken=$(jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
echo "logged in to server > ${server}"


echo "${PROJECT} ${IMAGE} ${INSTANCE} ${VM_USER} vm-app-"

for i in $(seq 1 ${8}); do
  INDEX=$((i - 1))

  echo "Run Setups on VM ${4}-${7}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${4}-${7}-vm-$INDEX \
    --resource-group ${4}-group \
    --scripts '
      cd /home/$4/vm
      chmod +x deploy.sh
      ./vm.sh
    ' \

  echo "Login Azure in VM ${4}-${7}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${4}-${7}-vm-$INDEX \
    --resource-group ${4}-group \
    --scripts '
         az login --service-principal --username ${1} --password ${2} --tenant ${3}
      ' \
    --parameters ${1} ${2} ${3}

  echo "Prepare VM ${4}-${7}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${4}-${7}-vm-$INDEX \
    --resource-group ${4}-group \
    --scripts "curl -s ${PREP_SCRIPT} | bash -s ${PROJECT} ${APP_SECRET} ${IMAGE} ${ENV} ${VIRTUAL_HOST} ${PORT} ${VM_USER}"

  echo "Login docker on VM ${4}-${7}-vm-$INDEX"
    az vm run-command invoke \
      --command-id RunShellScript \
      --name ${4}-${7}-vm-$INDEX \
      --resource-group ${4}-group \
      --scripts '
        echo "Login docker"
        docker login $1 --username 00000000-0000-0000-0000-000000000000 --password $2
      ' \
      --parameters "${server}" "${accessToken}"

  echo "Deploy Update on VM ${4}-${7}-vm-$INDEX"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${4}-${7}-vm-$INDEX \
    --resource-group ${4}-group \
    --scripts '
      cd /home/$4/vm
      ls -a
      chmod +x deploy.sh
      ./deploy.sh $1 $2 $3 $4 $5
    ' \
    --parameters "${PROJECT}" "${IMAGE}" "${INSTANCE}" "${VM_USER}" "vm-app-"
done