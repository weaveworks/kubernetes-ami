#!/bin/bash
#
#

kubeadm=`which kubeadm`
kubectl=`which kubectl`

kubeadm=`which echo`
kubectl=`which echo`

export PATH="$PATH:/usr/local/bin"

alias errout='>&2 echo'

errout() {
  echo 2>&1 $1
}

_k8s_token() {
  echo "token"
}

_k8s_lead_ip() {
  echo ""
}

do_install() {

  K8S_TOKEN=`_k8s_token`
  K8S_LEAD_IP=`_k8s_lead_ip`

  if [ ! -z "$K8S_TOKEN" ] && [ -z "$K8S_LEAD_IP" ]; then

    echo "This is a leader!"
    # This is a master, set up the Weave stuff
    $kubeadm init --token=${K8S_TOKEN} --cloud-provider=aws && \
    $kubectl apply -f https://git.io/weave-kube && \
    do_install_weavecloud 

  elif [ ! -z "$K8S_TOKEN" ] && [ ! -z "$K8S_LEAD_IP" ]; then

    echo "This is a node!"
    echo "K8S_TOKEN: $K8S_TOKEN"
    echo "K8S_LEAD_IP: $K8S_LEAD_IP"

    # This is a node, just join the cluster
    $kubeadm join --token=${K8S_TOKEN} --master-ip=${K8S_LEAD_IP}

  else
    errout "Needed at least a K8S_TOKEN, found: K8S_TOKEN=$K8S_TOKEN, K8S_LEAD_IP=$K8S_LEAD_IP"
    exit 1
  fi

}

do_install_weavecloud() {
  # check we actually have a Weave Cloud token
  if [ ! -z "$WEAVE_TOKEN" ]; then
    $kubectl apply -f https://git.io/weave-cloud/$WEAVE_TOKEN
  else 
    echo "Did not find a valid WEAVE_TOKEN: $WEAVE_TOKEN"
  fi
}



if [ ! `command -v curl` ]; then
  errout "'curl' command is required. See docs."
  exit 1
fi

if [ ! `command -v aws` ]; then
  errout "'aws' command is required. See docs."
  exit 1
fi

if [ ! `command -v jq` ]; then
  errout "'jq' command is required. See docs."
  exit 1
fi

jq=`which jq`
aws=`which aws`


do_install