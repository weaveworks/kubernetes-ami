# kubernetes-ami

A simple CloudFormation template and AMI builder for running Kubernetes on AWS EC2.

The AMI is built with (Packer)[https://www.packer.io/] and includes the Kubernetes packages for installation with `kubeadm`.

## Design

The CloudFormation template creates the following key components:

- Kubernetes master EC2 instance
- Auto Scaling Group for the Kubernetes minions
- SecurityGroup for Kubernetes & pod network comms

## Parameters

Required parameters:

- KubeCommunityAMI (AMI identifier)
- KeyName (EC2 KeyPair identifier)

Optional parameters:

- MasterInstanceType (default m4.large)
- NodeInstanceType (default m4.xlarge)
- Nodes (default 3)

## Outputs

Once the cluster is running, you need to login to it!

- MasterIP
- LoginToMasterCommand
- GetKubeconfigCommand
