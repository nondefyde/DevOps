#! /bin/bash

cd ../${1}
echo "Environment AWS: ${1} - ${2}"
mkdir -p _state
#terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64
terraform init -input=false -migrate-state \
-backend-config="bucket=${2}-tfstate" \
-backend-config="region=${3}" \
-backend-config="key=${2}.terraform.tfstate"

terraform plan -input=false -var-file=../../_env/${2}.aws.tfvars -out ./_state/${2}.tfplan
cd ../_scripts

echo "------ Preparation exited ------"
exit 0