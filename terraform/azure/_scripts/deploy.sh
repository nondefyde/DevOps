#! /bin/bash

echo "Deploy image to container"

RESOURCE_GROUP_NAME=${1}-group
RESOURCE_LOCATION=centralus
VM_NAME=${1}-vm
IMAGE=${2}
HOST=${3}
CONTAINER_NAME=${4}
PORT=${5}

echo "Login to container registry ${1}acr"

LOGIN_SERVER=$(az acr login -n ${1}acr --expose-token)

accessToken=$( jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )

echo "logged in to server > ${server}"

echo "Login to docker"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts 'sudo docker login $1 --username 00000000-0000-0000-0000-000000000000 --password $2' \
  --parameters ${server} ${accessToken}


echo "Cleanup previous deployment"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts '
       sudo docker stop $1
       sudo docker rmi $1
       sudo docker container stop $1
       sudo docker container rm $1
    ' \
  --parameters ${CONTAINER_NAME}

echo "Pull latest image from docker"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts 'sudo docker pull $1' \
  --parameters ${IMAGE}

echo "Deploy latest image to docker"
az vm run-command invoke \
  -g ${RESOURCE_GROUP_NAME} \
  -n ${VM_NAME} \
  --command-id RunShellScript \
  --scripts 'sudo docker run --name=$3 --restart=always -p $4:80 -e VIRTUAL_HOST=$1 -d $2' \
  --parameters ${HOST} ${IMAGE} ${CONTAINER_NAME} ${PORT}

echo "Successfully Deployed"