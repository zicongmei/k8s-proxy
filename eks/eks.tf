resource "aws_iam_role" "EKSClusterRole" {
  name = "${local.name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "${local.name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_eks_cluster" "eks" {
  name     = "${local.name}-eks"
  role_arn = aws_iam_role.EKSClusterRole.arn
  version = local.k8s_version
  vpc_config {
    subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  }

  depends_on = [
    aws_iam_role.EKSClusterRole,
  ]

  tags = { Name = "${local.name}-eks" }
}


resource "aws_eks_node_group" "node-ec2" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.name}-eks-nodegroup"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  version = local.k8s_version
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.micro"]
  disk_size      = 20

  depends_on = [
    aws_iam_role.NodeGroupRole,
  ]
}