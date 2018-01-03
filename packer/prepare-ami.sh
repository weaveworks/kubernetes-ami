#!/bin/bash -eux

kubernetes_release_tag="v1.9.0"
weave_net_release_tag="v2.1.3"

## Install official Kubernetes package

curl --silent "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

export DEBIAN_FRONTEND=noninteractive
apt_flags=(-o "Dpkg::Options::=--force-confnew" -qy)

apt-get update -q
apt-get upgrade "${apt_flags[@]}"
# TODO pin versions here
apt-get install "${apt_flags[@]}" docker.io kubelet kubeadm kubectl kubernetes-cni

## Also install `jq` and `pip`

apt-get install "${apt_flags[@]}" jq python-pip

## We will need AWS tools as well

pip install "https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz"
pip install awscli

## Install `weave` command and DaemonSet manifest YAML

curl --silent --location \
  "https://github.com/weaveworks/weave/releases/download/${weave_net_release_tag}/weave" \
  --output /usr/bin/weave

chmod 755 /usr/bin/weave

curl --silent --location \
  "https://cloud.weave.works/k8s/net?v=${weave_net_release_tag}&k8s-version=${kubernetes_release_tag}" \
  --output /etc/weave-net.yaml

## Pre-fetch Kubernetes release image, so that `kubeadm init` is a bit quicker

images=(
  "gcr.io/google_containers/kube-proxy-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-apiserver-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-scheduler-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/etcd-amd64:3.1.10"
  "gcr.io/google_containers/pause-amd64:3.0"
  "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7"
  "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7"
  "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7"
  "weaveworks/weave-npc:${weave_net_release_tag/v/}"
  "weaveworks/weave-kube:${weave_net_release_tag/v/}"
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
