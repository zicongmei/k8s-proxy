locals {
  dollar = "$"
}
locals {
  no_proxy = "172.20.0.0/16,localhost,127.0.0.1,${aws_vpc.this.cidr_block},169.254.169.254,.internal,s3.amazonaws.com,.s3.${local.region}.amazonaws.com,api.ecr.${local.region}.amazonaws.com,dkr.ecr.${local.region}.amazonaws.com,ec2.${local.region}.amazonaws.com"

  # reference https://repost.aws/knowledge-center/eks-http-proxy-configuration-automation
  nodepool-userdata = <<EOD
Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version:  1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

#!/bin/bash
set -o xtrace

#Set the proxy hostname and port
PROXY="${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac/)
VPC_CIDR=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-blocks | xargs | tr ' ' ',')

#Create the docker systemd directory
mkdir -p /etc/systemd/system/docker.service.d

#Configure yum to use the proxy
cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
proxy=http://$PROXY
EOF

#Set the proxy for future processes, and use as an include file
cloud-init-per instance proxy_config cat << EOF >> /etc/environment
http_proxy=http://$PROXY
https_proxy=http://$PROXY
HTTP_PROXY=http://$PROXY
HTTPS_PROXY=http://$PROXY
no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254
NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254
EOF

#Configure docker with the proxy
cloud-init-per instance docker_proxy_config tee <<EOF /etc/systemd/system/docker.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Configure the kubelet with the proxy
cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
[Service]
EnvironmentFile=/etc/environment
EOF

#Reload the daemon and restart docker to reflect proxy configuration at launch of instance
cloud-init-per instance reload_daemon systemctl daemon-reload
cloud-init-per instance enable_docker systemctl enable --now --no-block docker


--==BOUNDARY==
Content-Type:text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace

#Set the proxy variables before running the bootstrap.sh script
set -a
source /etc/environment

SCRIPT=$(ls /var/lib/cloud/instances/*/scripts/part-003)

while true; do
timeout 60  ${local.dollar}{SCRIPT}  && break
done

--==BOUNDARY==--
EOD
}


resource "aws_launch_template" "proxy-template" {
  name = "${local.name}-launchtemplate"

  user_data = base64encode(local.nodepool-userdata)
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  key_name = aws_key_pair.this.key_name
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-eks-lt"
    }
  }
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
}
