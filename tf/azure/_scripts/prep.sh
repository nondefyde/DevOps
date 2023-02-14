#! /bin/bash

#echo "Generate docker compose file"
#cat ./ci/docker-compose.yml | envsubst > ./vm/docker-compose.yml

echo "Check if reverse proxy is running"
IMAGE_COUNT=$(sudo docker ps --filter="name=reverse_proxy" | grep reverse_proxy | wc -l)
ZERO=0
if [ $IMAGE_COUNT -gt 0 ]; then
  echo "Reverse Proxy is working"
#  curl s https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/_scripts/deploy.sh
#  chmod a+x ./deploy.sh
#  ./deploy.sh $2
else
  sudo docker pull jwilder/nginx-proxy:latest
  sudo docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name reverse_proxy --net nginx-proxy jwilder/nginx-proxy
fi


