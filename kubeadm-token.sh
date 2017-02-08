#!/bin/bash
#

generate_random() {
  TOKEN=`head -c 32 /dev/urandom | base64 | tr -c [a-zA-Z0-9] -d | head -c $1`
  echo $TOKEN
}

echo "$(generate_random 6).$(generate_random 16)"
