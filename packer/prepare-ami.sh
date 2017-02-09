#!/bin/bash -eux

kubernetes_release_tag="v1.5.2"

## Install official Kubernetes package

curl --silent "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update -q
apt-get upgrade -qy
# TODO pin versions here
apt-get install -qy docker.io kubelet kubeadm kubectl kubernetes-cni

## Also install `jq` and `pip`

apt-get install -qy jq python-pip

## We will need AWS tools as well

pip install "https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz"
pip install awscli

## Install `weave` command and DaemonSet manifest YAML

curl --silent --location \
  "https://github.com/weaveworks/weave/releases/download/v1.9.0/weave" \
  --output /usr/bin/weave

chmod 755 /usr/bin/weave

curl --silent --location \
  "https://github.com/weaveworks/weave/releases/download/v1.9.0/weave-daemonset.yaml" \
  --output /etc/weave-daemonset.yaml

## Pre-fetch Kubernetes release image, so that `kubeadm init` is a bit quicker

images=(
  "gcr.io/google_containers/kube-proxy-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-apiserver-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-scheduler-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/etcd-amd64:3.0.14-kubeadm"
  "gcr.io/google_containers/kube-discovery-amd64:1.0"
  "gcr.io/google_containers/pause-amd64:3.0"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done

## Save release version, so that we can call `kubeadm init --use-kubernetes-version="$(cat /etc/kubernetes_community_ami_version)` and ensure we get the same version
echo "${kubernetes_release_tag}" > /etc/kubernetes_community_ami_version

## Cleanup packer SSH key and machine ID generated for this boot

rm /root/.ssh/authorized_keys
rm /home/ubuntu/.ssh/authorized_keys
rm /etc/machine-id
touch /etc/machine-id

## Done!
