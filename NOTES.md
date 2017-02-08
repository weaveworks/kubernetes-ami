To use `kubectl` from your laptop, run `scp ubuntu@<mastr_ip>:kubeconfig ~/.kube/config`.

If something goes wrong, firt check the output of `kubeadm` which can be found in `/var/log/cfn-init-cmd.log` on master and node.
