# Get Started with Kubernetes on AWS using CloudFormation

A simple CloudFormation template and AMI builder for running Kubernetes on AWS EC2.

The AMI is built with [Packer](https://www.packer.io/) and includes the Kubernetes packages for installation with `kubeadm`.

## Design

The CloudFormation template creates the following key components:

- Kubernetes master EC2 instance
- Auto Scaling Group for the Kubernetes minions
- Security Group for Kubernetes & pod network comms

## Parameters

Required parameters:

- `KubeCommunityAMI` (AMI identifier)
- `KeyName` (EC2 SSH key pair identifier)
- `NetworkAddon` (Can be `Weave` or `NONE`, more to be added)

Optional parameters:

- `MasterInstanceType` (default _`m4.large`_)
- `NodeInstanceType` (default _`m4.xlarge`_)
- `Nodes` (default 3)

## Outputs

Once the cluster is running, you need to login to it!

- `MasterIP`
- `LoginToMasterCommand`
- `GetKubeconfigCommand`

## Deployment Instructions

There is `ami-0c29b36c` published in `us-west-2`.

You will need to have an EC2 key in `us-west-2` region.

To create a stack, first clone this repo:
```
git clone https://github.com/weaveworks/kubernetes-ami
cd kubernetes-ami
```

Next, copy the command shown above and replace `<YOUR_EC2_KEY_NAME>`
with the name of your SSH key in `us-west-2` region.

```
aws cloudformation create-stack \
    --stack-name kube-getting-started \
    --region us-west-2 \
    --template-body "file://cloudformation.json" \
    --parameters \
      ParameterKey=KeyName,ParameterValue=<YOUR_EC2_KEY_NAME> \
      ParameterKey=KubeCommunityAMI,ParameterValue=ami-0c29b36c
```

By default a 3-node cluster will be deployed, which takes a few minutes...
You can run the following command to check the status of the stack.

```
> aws --region us-west-2 cloudformation describe-stacks --stack-name kube-getting-started
{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:us-west-2:992485676579:stack/kube-getting-started/802a0dad-ad8f-4273-b240-a0f313e1b288",
            "Description": "Getting Started with Kubernetes",
            "Parameters": [
                {
                    "ParameterValue": "<YOUR_EC2_KEY_NAME>",
                    "ParameterKey": "KeyName"
                },
                {
                    "ParameterValue": "ami-847efbe4",
                    "ParameterKey": "KubeCommunityAMI"
                },
                {
                    "ParameterValue": "m4.large",
                    "ParameterKey": "MasterInstanceType"
                },
                {
                    "ParameterValue": "m4.xlarge",
                    "ParameterKey": "NodeInstanceType"
                },
                {
                    "ParameterValue": "Weave",
                    "ParameterKey": "NetworkAddon"
                },
                {
                    "ParameterValue": "3",
                    "ParameterKey": "Nodes"
                }
            ],
            "Tags": [],
            "Outputs": [
                {
                    "OutputKey": "GetKubeconfigCommand",
                    "OutputValue": "scp -i <YOUR_EC2_KEY_NAME>.pem ubuntu@52.36.245.255:kubeconfig ./kubeconfig"
                },
                {
                    "OutputKey": "LoginToMasterCommand",
                    "OutputValue": "ssh -i <YOUR_EC2_KEY_NAME>.pem ubuntu@52.36.245.255"
                },
                {
                    "OutputKey": "MasterIP",
                    "OutputValue": "52.36.245.255"
                }
            ],
            "CreationTime": "2017-02-10T16:14:26.733Z",
            "StackName": "kube-getting-started",
            "NotificationARNs": [],
            "StackStatus": "CREATE_COMPLETE",
            "DisableRollback": false
        }
    ]
}
```

As you can see the `Outputs` section provides a few handy commands you can use to access the cluster.

Have fun using Kubernetes on AWS!
