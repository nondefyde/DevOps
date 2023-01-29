#! /bin/bash

IMAGE_COUNT=$(sudo docker ps | grep $1 | wc -l)
IDS=$(sudo docker ps --filter ancestor=$1 --format '{{.ID}}')
ZERO=0

echo "Number of container running image is ${IMAGE_COUNT}"

if [ $IMAGE_COUNT -gt 0 ]; then
  NEWCOUNT=$((IMAGE_COUNT+1))
  echo "Spin up new container with updated image to scale up to ${NEWCOUNT}"

  sudo docker-compose pull app
  sudo docker-compose up -d --scale app=$NEWCOUNT --no-recreate

  UPDATED_IMAGE_COUNT=$(sudo docker ps | grep $1 | wc -l)
  echo "UPDATED_IMAGE_COUNT >>>>> ${UPDATED_IMAGE_COUNT}"
  if [ $UPDATED_IMAGE_COUNT -ge $NEWCOUNT ]; then
    for id in $IDS; do
      echo "Destroy old container running id ${id}"
      sudo docker stop $id
      sudo docker rm -f $id
    done
    echo "Scaling down to 1"
    sudo docker-compose up -d --scale app=1 --no-recreate
  fi
else
  echo "Spin up new container"
  sudo docker-compose up -d --scale app=1 --no-recreate
fi