#! /bin/bash

echo "Project     : $1"
echo "image       : $2"
echo "instance    : $3"
echo "Vm user     : $4"
echo "App alias   : $5"

echo "Use docker rootless"
docker context use rootless

echo "Remove unused images as part of cleaning up"
docker image prune -a -f

APP_ALIAS=$5

IMAGE_COUNT=$(docker ps --filter="name=${APP_ALIAS}*" | grep "${APP_ALIAS}" | wc -l)
IDS=$(docker ps --filter ancestor=$1 --format '{{.ID}}')
ZERO=0

echo "Number of container running image is ${IMAGE_COUNT}"

if [ $IMAGE_COUNT -gt 0 ]; then
  NEWCOUNT=$((IMAGE_COUNT+$3))
  echo "Spin up new container with updated image to scale up to ${NEWCOUNT}"

  docker compose pull app
  docker compose up -d --scale app=$NEWCOUNT --no-recreate

  UPDATED_IMAGE_COUNT=$(docker ps --filter="name=${APP_ALIAS}*" | grep "${APP_ALIAS}" | wc -l)
  echo "Updated image >>>>> ${UPDATED_IMAGE_COUNT} >>>>> new Image count ${NEWCOUNT}"
  if [ $UPDATED_IMAGE_COUNT -ge $NEWCOUNT ]; then
    for id in $IDS; do
      echo "Destroy old container running id ${id}"
      sudo docker stop $id
      sudo docker rm -f $id
    done
    echo "Scaling down to ${3}"
    docker compose up -d --scale app="${3}" --no-recreate
  fi
else
  echo "Spin up ${3} new container instance"
  docker compose up
#  docker compose up -d --scale app="${3}" --no-recreate
fi