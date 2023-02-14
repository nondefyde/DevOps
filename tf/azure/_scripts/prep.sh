#! /bin/bash

trap 'echo Error: Command failed; exit 1' ERR

echo "Project       : ${1}"
echo "App Secret    : ${2}"
echo "Image         : ${3}"
echo "Environment   : ${4}"
echo "Virtual Host  : ${5}"
echo "Port          : ${6}"
echo "Vm User       : ${7}"


echo "Generate env file"
rm -rf "/home/${7}/vm"
mkdir "/home/${7}/vm"
touch "/home/${7}/vm/.env"
DECODED=$(echo "${2}" | base64 --decode > /home/adminuser/vm/.env)

echo "Generate docker compose file"
DOCKER_COMPOSE_FILE=https://raw.githubusercontent.com/nondefyde/DevOps/main/ci/docker-compose.yml

curl -sSL "${DOCKER_COMPOSE_FILE}" | sed "s;{IMAGE};$3;g; s;{NODE_ENV};$4;g; s;{VIRTUAL_HOST};$5;g; s;{PORT};$6;g" > "/home/${7}/vm/docker-compose.yml"


#echo "Login to container registry ${1}acr"
#LOGIN_SERVER=$(az acr login -n ${1}acr --expose-token)
#accessToken=$( jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
#server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
#
#echo "Logged in docker to server >> ${server}"
#sudo docker login ${server} --username 00000000-0000-0000-0000-000000000000 --password ${accessToken}
#
#echo "Check if reverse proxy is running"
#IMAGE_COUNT=$(sudo docker ps --filter="name=reverse_proxy" | grep reverse_proxy | wc -l)
#ZERO=0
#echo "IMAGE_COUNT ${IMAGE_COUNT}"
#if [ $IMAGE_COUNT -gt 0 ]; then
#  echo "Reverse Proxy present"
##  curl s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/deploy.sh
##  chmod a+x ./deploy.sh
##  ./deploy.sh $2
#else
#  sudo docker pull jwilder/nginx-proxy:latest
#  sudo docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name reverse_proxy --net nginx-proxy jwilder/nginx-proxy
#fi
#

