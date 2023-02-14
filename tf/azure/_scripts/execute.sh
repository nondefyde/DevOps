#! /bin/bash

echo "Run Deployment"

echo "Project     : ${1}"
echo "Image       : ${2}"
echo "App Secret  : ${3}"
echo "Vm Name     : ${4}"
echo "Vm Count    : ${5}"

echo "Cleanup previous deployment"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts '
       sudo mkdir vm
       sudo touch vm/.env
       DECODED=$(echo $3 | base64 --decode > vm/.env)
    ' \
  --parameters ${CONTAINER_NAME}

echo "Login to docker"
echo "Login to container registry ${1}acr"
LOGIN_SERVER=$(az acr login -n ${1}acr --expose-token)
accessToken=$( jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
echo "logged in to server > ${server}"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts 'sudo docker login $1 --username 00000000-0000-0000-0000-000000000000 --password $2' \
  --parameters ${server} ${accessToken}


echo "Deploy to VM"
for i in $(seq 1 ${5}); do
  echo "Run Command on VM ${1}-${4}-vm-$i"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${1}-${4}-vm-$i \
    --resource-group ${1}-group \
    --scripts "curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s $1 $2 $3"
done


