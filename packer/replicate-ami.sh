#!/bin/bash

set -eu

readonly source_region='us-west-2'

readonly source_image="${1}"

readonly name="$(aws ec2 describe-images --region "${source_region}" --image-ids "${source_image}" | jq -r '.Images[0].Name')"

readonly regions=(
  "ap-northeast-1"
  "ap-northeast-2"
  "ap-south-1"
  "ap-southeast-1"
  "ap-southeast-2"
  "ca-central-1"
  "eu-central-1"
  "eu-west-1"
  "eu-west-2"
  "sa-east-1"
  "us-east-1"
  "us-east-2"
  "us-west-1"
)

new_images="$(jq -n ".\"${source_region}\"={ImageId:\"${source_image}\"}")"

for destination_region in "${regions[@]}" ; do
  new_image="$(aws ec2 copy-image --source-image-id "${source_image}" --source-region "${source_region}" --region ap-northeast-1 --name "${name}")"
  new_images="$(echo "${new_images}" | jq ".\"${destination_region}\"=${new_image}")"
done

echo "${new_images}"
