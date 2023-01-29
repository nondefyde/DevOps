#! /bin/bash

IMAGE_COUNT=$(sudo docker ps | grep $1 | wc -l)
IMAGES=$(sudo docker ps --filter ancestor=$1 --format '{{.Names}}')
ZERO=0

echo "Number of container running image is ${IMAGE_COUNT}"

if [ "$IMAGE_COUNT" -gt 0 ]; then
  NEWCOUNT=$((IMAGE_COUNT+1))
  echo "Spin up new container with updated image to scale up to ${NEWCOUNT}"

  sudo docker-compose pull app
  sudo docker-compose up -d --scale app=$NEWCOUNT --no-recreate

  UPDATED_IMAGE_COUNT=$(sudo docker ps | grep $1 | wc -l)
  if [ "$UPDATED_IMAGE_COUNT" -e "$NEWCOUNT" ]; then
    for image in $IMAGES; do
      echo "Destroy old container running image ${image}"
      sudo docker rm -f $image
    done
  fi
else
  echo "Spin up new container"
  sudo docker-compose pull app
  sudo docker-compose up -d --scale app=1 --no-recreate
fi