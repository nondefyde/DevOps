#!/bin/bash

REGION=us-west-2
BUCKET_NAME=${1}-tfstate

echo "Setting up bucket ${BUCKET_NAME} within region ${REGION}"

if aws s3api head-bucket --bucket ${BUCKET_NAME} --region ${REGION} 2>/dev/null;
then
  echo "${BUCKET_NAME} bucket already created by user"
else
  echo "Creating ${BUCKET_NAME} bucket"
  aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${REGION} --create-bucket-configuration LocationConstraint=${REGION}
  echo "${BUCKET_NAME} bucket created successfully"
fi