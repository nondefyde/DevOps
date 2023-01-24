#!/bin/bash

apt-get update
programs=(bc eksctl)

for program in "${programs[@]}"; do
    if ! command -v "$program" > /dev/null 2>&1; then
        apt-get install "$program" -y
    fi
done