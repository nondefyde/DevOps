#! /bin/bash

cd ../${1}
terraform apply -auto-approve ./_state/${2}.tfplan
cd ../_scripts

echo "Application completed"
exit 0