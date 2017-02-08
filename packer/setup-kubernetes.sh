#!/bin/bash
#
# One time launch
#
#####################################################################

export PATH="$PATH:/usr/local/bin"
WEAVE_CLOUD_URL=${WEAVE_CLOUD_LAUNCHER_URL:-launch.weave.cloud}

alias errout='>&2 echo'

#####################################################################

errout() {
  echo 2>&1 $1
}

_k8s_token() {
  echo "kubernetes.token"
}

_k8s_lead_ip() {
  echo "0.0.0.0"
}

_weave_cloud_token() {
  echo "TOKEN_FOO_BAR"
}

do_install() {

  KUBERNETES_TOKEN=`_k8s_token`
  KUBERNETES_LEAD_IP=`_k8s_lead_ip`
  WEAVE_CLOUD_TOKEN=`_weave_cloud_token`

  echo "KUBERNETES_TOKEN: $KUBERNETES_TOKEN"
  echo "KUBERNETES_LEAD_IP: $KUBERNETES_LEAD_IP"
  echo "WEAVE_CLOUD_TOKEN: $WEAVE_CLOUD_TOKEN"

  if [ ! -z "$KUBERNETES_TOKEN" ] && [ -z "$KUBERNETES_LEAD_IP" ]; then

    echo "This is a leader!"
    # This is a master, set up the Weave stuff
    $kubeadm init --token=${KUBERNETES_TOKEN} --cloud-provider=aws && \
    $kubectl apply -f https://git.io/weave-kube && \
    do_install_weavecloud 

  elif [ ! -z "$KUBERNETES_TOKEN" ] && [ ! -z "$KUBERNETES_LEAD_IP" ]; then

    echo "This is a node!"
    # This is a node, just join the cluster
    $kubeadm join --token=${KUBERNETES_TOKEN} --master-ip=${KUBERNETES_LEAD_IP}

  else
    errout "Needed at least a KUBERNETES_TOKEN, found: KUBERNETES_TOKEN=$KUBERNETES_TOKEN, KUBERNETES_LEAD_IP=$KUBERNETES_LEAD_IP"
    exit 1
  fi
}

do_install_weavecloud() {
  # check we actually have a Weave Cloud token
  if [ ! -z "$WEAVE_CLOUD_TOKEN" ]; then
    $kubectl apply -f https://${WEAVE_CLOUD_URL}/${WEAVE_CLOUD_TOKEN}
  else 
    echo "Did not find a valid WEAVE_CLOUD_TOKEN: $WEAVE_CLOUD_TOKEN"
  fi
}

#####################################################################

kubeadm=`which kubeadm`
kubectl=`which kubectl`

# if there's an existing kubelet, don't do the install
if [ ! -f /etc/kubernetes/manifests ]; then
  do_install
else
  errout "Kubernetes is probably already installed. Found '/etc/kubernetes/manifests'."
fi
