#! /bin/bash

echo "Remove unused images as part of cleaning up"
sudo docker image prune -a -f

echo "acr $1"

IMAGE_COUNT=$(sudo docker ps --filter="name=vm-app-*" | grep vm-app- | wc -l)
IDS=$(sudo docker ps --filter ancestor=$1 --format '{{.ID}}')
ZERO=0

echo "Number of container running image is ${IMAGE_COUNT}"

if [ $IMAGE_COUNT -gt 0 ]; then
  NEWCOUNT=$((IMAGE_COUNT+1))
  echo "Spin up new container with updated image to scale up to ${NEWCOUNT}"

  docker compose pull app
  docker compose up -d --scale app=$NEWCOUNT --no-recreate

  UPDATED_IMAGE_COUNT=$(sudo docker ps --filter="name=vm-app-*" | grep vm-app- | wc -l)
  echo "Updated image >>>>> ${UPDATED_IMAGE_COUNT} >>>>> new Image count ${NEWCOUNT}"
  if [ $UPDATED_IMAGE_COUNT -ge $NEWCOUNT ]; then
    for id in $IDS; do
      echo "Destroy old container running id ${id}"
      sudo docker stop $id
      sudo docker rm -f $id
    done
    echo "Scaling down to 1"
    docker compose up -d --scale app=1 --no-recreate
  fi
else
  echo "Spin up new container"
  docker compose up -d --scale app=1 --no-recreate
fi