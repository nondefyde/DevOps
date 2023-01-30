#!/usr/bin/env bash

echo File name $1

#!/usr/bin/.env bash
if [[ "${OSTYPE}" = darwin* ]]; then
  # OSX
  if [ -t 0 ]; then
    base64 "$@"
  else
    cat /dev/stdin | base64 "$@"
  fi
else
  # Linux
  if [ -t 0 ]; then
    base64 -w 0 "$@"
  else
    cat /dev/stdin | base64 -w 0 "$@"
  fi
fi