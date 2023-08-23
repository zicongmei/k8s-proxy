locals {
  instance_type = "t3.nano"
  ami           = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20221212"
  ami_type      = "hvm"
  ami_owner     = "099720109477"
  volume_type   = "gp3"
  volume_size   = 10
}

resource "aws_key_pair" "this" {
  key_name   = "${local.name}-keypair"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

data "aws_ami" "this" {
  filter {
    name   = "name"
    values = [local.ami]
  }
  filter {
    name   = "virtualization-type"
    values = [local.ami_type]
  }
  owners      = [local.ami_owner]
  most_recent = true
}

resource "aws_security_group" "allow-ssh" {
  name        = "${local.name}-ssh-sg"
  description = "allow ssh"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "open to all ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${local.name}-ssh-sg" }
}
