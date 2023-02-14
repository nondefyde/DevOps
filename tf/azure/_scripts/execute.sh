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

for i in $(seq 1 ${5}); do
  echo "Run Command on VM ${1}-${4}-vm-$i"
  az vm run-command invoke \
    --command-id RunShellScript \
    --name ${1}-${4}-vm-$i \
    --resource-group ${1}-group \
    --scripts "curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s $1 $2 $3"
done


