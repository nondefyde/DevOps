#! /bin/bash


echo "Run Deployment"

echo "Project     : ${1}"
echo "Image       : ${2}"
echo "App Secret  : ${3}"
echo "Vm Name     : ${4}"
echo "Vm Count    : ${5}"


for i in $(seq 1 ${5}); do
    az vm run-command invoke
      --command-id RunShellScript
      --name ${1}-${4}-vm-$i
      --resource-group ${{ env.project }}-group
      --scripts "curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s $1 $2 $3"
done


