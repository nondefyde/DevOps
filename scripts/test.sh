#!/usr/bin/env bash

echo File name $1

outputs=$(cat $1)
for key in $(echo $outputs | jq -r 'keys[]'); do
  KEY=$(echo "${key}" | tr '[:lower:]' '[:upper:]')
  VALUE=$(echo "${outputs}" | jq -r ".${key}.value")
  echo "key == $KEY"
  echo "value == $VALUE"
done