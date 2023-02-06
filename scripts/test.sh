#!/usr/bin/env bash

echo File name $1

outputs=$(cat $1)
#echo $outputs
list=$(echo $outputs | jq -r keys[])
echo $list
#for key in $(echo "${outputs}" | jq -r 'keys[]'); do
#  KEY=$(echo "${key}")
#  VALUE=$(echo "${outputs}" | jq -r ".${key}.value")
##  echo "key == $KEY"
##  echo "value == $VALUE"
#  export TF_OUTPUT_$KEY=$VALUE
#done