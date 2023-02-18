#! /bin/bash

while [ "$(hostname -I)" = "" ]; do
  echo -e "\e[1A\e[KNo network: $(date)"
  sleep 1
done
echo "I have network";

curl -s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/vm/_scripts/vm.sh | bash -s



