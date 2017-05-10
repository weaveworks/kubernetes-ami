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
  echo "Copying to ${destination_region}..."
  new_image="$(aws ec2 copy-image --source-image-id "${source_image}" --source-region "${source_region}" --region "${destination_region}" --name "${name}")"
  new_images="$(echo "${new_images}" | jq ".\"${destination_region}\"=${new_image}")"
done

for destination_region in "${regions[@]}" ; do
  new_image_id="$(echo "${new_images}" | jq -r ".\"${destination_region}\".ImageId")"
  echo "Waiting for new image (${new_image_id}) to become available..."
  while test "$(aws ec2 describe-images --region "${destination_region}" --image-ids "${new_image_id}" | jq -r '.Images[0].State')" == "pending" ; do sleep 5 ; done
  aws ec2 modify-image-attribute --region "${destination_region}" --image-id "${new_image_id}" --launch-permission "{\"Add\": [{\"Group\":\"all\"}]}"
  echo "Image ${new_image_id} in ${destination_region} is now public."
done

echo "${new_images}"
