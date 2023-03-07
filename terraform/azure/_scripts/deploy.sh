#! /bin/bash

echo "Project     : $1"
echo "image       : $2"
echo "App alias   : $3"

echo "Deploy App $1"

echo "Remove unused images as part of cleaning up"
docker image prune -a -f

APP_ALIAS=$3

IMAGE_COUNT=$(docker ps --filter="name=${APP_ALIAS}*" | grep "${APP_ALIAS}" | wc -l)
IDS=$(docker ps --filter ancestor=$2 --format '{{.ID}}')
ZERO=0
echo "Number of container running image is ${IMAGE_COUNT}"
if [ $IMAGE_COUNT -gt 0 ]; then
  docker compose pull app
  docker compose up -d
else
  echo "Spin up new container instance"
  docker compose version
  docker compose up -d
fi