# resuired by EKS. https://repost.aws/knowledge-center/eks-http-proxy-configuration-automation

resource "kubernetes_config_map" "proxy" {
  metadata {
    name = "proxy-environment-variables"
    namespace = "kube-system"
  }
  data = {
    HTTP_PROXY = "http://${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
    HTTPS_PROXY  = "http://${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
    NO_PROXY = "172.20.0.0/16,localhost,127.0.0.1,${aws_vpc.this.cidr_block},169.254.169.254,.internal,s3.amazonaws.com,.s3.${local.region}.amazonaws.com,api.ecr.${local.region}.amazonaws.com,dkr.ecr.${local.region}.amazonaws.com,ec2.${local.region}.amazonaws.com"
  }
  depends_on = [aws_eks_cluster.eks]
}
