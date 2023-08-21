resource "aws_iam_role" "eks-iam-role" {
  name = "${local.name}-eks-role"

  path = "/"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

resource "aws_eks_cluster" "eks" {
  name     = "${local.name}-eks"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]

  tags = { Name = "${local.name}-eks" }
}


resource "aws_eks_node_group" "node-ec2" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.name}-eks-nodegroup"
  node_role_arn   = aws_iam_role.eks-iam-role.arn
  subnet_ids      = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.micro"]
  disk_size      = 20

}