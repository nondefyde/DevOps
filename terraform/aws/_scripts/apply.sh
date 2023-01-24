#! /bin/bash

cd ../${1}
terraform apply -refresh=false -auto-approve ./_state/${2}.tfplan
cd ../_scripts

echo "Application completed"
exit 0