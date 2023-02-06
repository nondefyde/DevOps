#!/usr/bin/env bash

echo File name $1

outputs=$(cat $1)
for key in $(echo $outputs | jq -r 'keys[]'); do
  KEY=$(echo "${key}")
  VALUE=$(echo "${outputs}" | jq -r ".${key}.value")
  echo "export $KEY=$VALUE"
  export "$KEY=$VALUE"
  echo "$KEY=$VALUE"
done