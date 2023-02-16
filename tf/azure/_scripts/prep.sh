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
DOCKER_COMPOSE_FILE=https://raw.githubusercontent.com/nondefyde/DevOps/main/ci/compose.tpl
curl -sSL "${DOCKER_COMPOSE_FILE}" | sed "s;{IMAGE};$3;g; s;{NODE_ENV};$4;g; s;{VIRTUAL_HOST};$5;g; s;{PORT};$6;g;"  > "/home/${7}/vm/docker-compose.yml"

echo "Copy deploy script"
DEPLOY_FILE=https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/deploy.sh
curl -sSL "${DEPLOY_FILE}" > "/home/${7}/vm/deploy.sh"



