#! /bin/bash


echo "Run Deployment"

az vm run-command invoke
  --command-id RunShellScript
  --name ${{ env.project }}-${{ matrix.items }}-vm-1
  --resource-group ${{ env.project }}-group
  --scripts "curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/prep.sh | bash -s $1 $2 $3"
