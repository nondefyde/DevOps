#! /bin/bash

echo "Environment AWS: ${1} - ${2}"
cd ../${1}
terraform plan -destroy -input=false -var-file=../../_env/${2}.aws.tfvars -out ./_state/${2}.destroy.tfplan
terraform apply ./_state/${2}.destroy.tfplan
cd ../_scripts

echo "----- Destruction existed --------"
exit 0