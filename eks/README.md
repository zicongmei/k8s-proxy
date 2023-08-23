# EKS behind proxy

## Usage

Creation:

```shell
terraform init
terraform apply
```

Deletion

```shell
terraform destroy
```

## Components

Components in public subnet
1. Public EC2. Used for ssh bastion and proxy server.
2. EC2 for NAT. For debugging only. Disabled now by blocking security group.

Components in private subnet
1. Private EC2. For debugging subnet issues.
2. EKS and a nodegroup. 