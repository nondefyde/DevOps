#!/bin/bash

source .secret
DECODED=$(echo $AZR_VM_APP_SECRET | base64 --decode > .env)