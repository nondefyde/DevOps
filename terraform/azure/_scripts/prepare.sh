#! /bin/bash

cd ../${1}
echo "Environment AZURE: ${1} - ${2}"
mkdir -p _state
#terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64
terraform init -input=false -upgrade -migrate-state \
-backend-config="resource_group_name=${2}-tfstate" \
-backend-config="storage_account_name=${2}storage" \
-backend-config="container_name=${2}tfstate" \
-backend-config="key=${2}.terraform.tfstate"

terraform plan -input=false -var-file=../../_env/${2}.azure.tfvars -out ./_state/${2}.tfplan
cd ../_scripts

echo "------ Preparation exited ------"
exit 0