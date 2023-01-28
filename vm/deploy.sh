#! /bin/bash

echo "Login to container registry ${1}acr"
LOGIN_SERVER=$(az acr login -n ${1}acr --expose-token)
accessToken=$( jq -r  '.accessToken' <<< "${LOGIN_SERVER}")
server=$( jq -r  '.loginServer' <<< "${LOGIN_SERVER}" )
echo "Login Successful"

IMAGE_COUNT=$(sudo docker ps | grep node-server:latest | wc -l)
IMAGES=$(sudo docker ps --format '{{.Names}}')
ZERO=0

echo "Number of container running image is ${IMAGE_COUNT}"

if [ "$IMAGE_COUNT" -gt "$ZERO" ]; then
  NEWCOUNT=$((IMAGE_COUNT+1))
  echo "Spin up new container with updated image to scale up to ${NEWCOUNT}"

  sudo docker-compose up -d --scale app=$NEWCOUNT --no-recreate

  for image in $IMAGES; do
    echo "Destroy old container running image ${image}"
    sudo docker rm -f $image
  done

else
  echo "Spin up new container"
  sudo docker-compose up -d --scale app=1 --no-recreate
fi