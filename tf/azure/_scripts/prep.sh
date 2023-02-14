#! /bin/bash

echo "Add env file"
mkdir vm
touch vm/.env
echo "Added folder"
#DECODED=$(echo $3 | base64 --decode > vm/.env)
#
#echo "Generate docker compose file"
#cat ./ci/docker-compose.yml | envsubst > ./vm/docker-compose.yml
#
#echo "Login docker"
#LOGIN_SERVER=$(az acr login -n "${1}acr" --expose-token)
#accessToken=$( jq -r  '.accessToken' <<< "${LOGIN_SERVER}" )
#server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
#
#sudo docker login ${server} --username 00000000-0000-0000-0000-000000000000 --password ${accessToken}
#
#echo "Check if reverse proxy is running"
#IMAGE_COUNT=$(sudo docker ps --filter="name=reverse_proxy" | grep reverse_proxy | wc -l)
#ZERO=0
#if [ $IMAGE_COUNT -gt 0 ]; then
#  curl s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/deploy.sh
#  chmod a+x ./deploy.sh
#  ./deploy.sh $2
#else
#  sudo docker pull jwilder/nginx-proxy:latest
#  sudo docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name reverse_proxy --net nginx-proxy jwilder/nginx-proxy
#fi
#

