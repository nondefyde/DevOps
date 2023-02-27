#! /bin/bash

echo "Run Setups"

if command -v curl >/dev/null 2>&1; then
    # Run your command here
    echo "curl is enabled"
else
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    echo "Installed curl"
fi

if command -v az &> /dev/null
then
    echo "Azure CLI is installed."
else
    sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    sudo apt-get install jq --yes
    echo "Installed Azure CLI & jq"
fi

echo "Run VM Setup scripts"
VM_SETUP=https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/vm/_scripts/vm.sh
sudo curl -sL "${VM_SETUP}" | sudo bash


echo "Project       : ${1}"
echo "App Secret    : ${2}"
echo "Image         : ${3}"
echo "Environment   : ${4}"
echo "Virtual Host  : ${5}"
echo "Port          : ${6}"
echo "Vm User       : ${7}"
echo "Cert Path     : ${8}"

echo "Generate env file"
rm -rf "/home/${7}/vm"
mkdir "/home/${7}/vm"
touch "/home/${7}/vm/.env"
DECODED=$(echo "${2}" | base64 --decode > /home/adminuser/vm/.env)

echo "Copy deploy script"
DEPLOY_FILE=https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/deploy.sh
curl -sSL "${DEPLOY_FILE}" > "/home/${7}/vm/deploy.sh"

echo "Generate docker compose file"
DOCKER_COMPOSE_FILE=https://raw.githubusercontent.com/nondefyde/DevOps/main/ci/compose.tpl
curl -sSL "${DOCKER_COMPOSE_FILE}" | sed "s;{IMAGE};$3;g; s;{NODE_ENV};$4;g; s;{VIRTUAL_HOST};$5;g; s;{PORT};$6;g; s;{CERT_PATH};$8;g;"  > "/home/${7}/vm/docker-compose.yml"



