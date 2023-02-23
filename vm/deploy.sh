#! /bin/bash

echo "Remove unused images as part of cleaning up"
sudo docker image prune -a -f

sudo  docker compose pull app
sudo  docker compose up -d