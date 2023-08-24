# resuired by EKS. https://repost.aws/knowledge-center/eks-http-proxy-configuration-automation

resource "kubernetes_config_map" "proxy" {
  metadata {
    name      = "proxy-environment-variables"
    namespace = "kube-system"
  }
  data = {
    HTTP_PROXY  = "http://${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
    HTTPS_PROXY = "http://${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
    NO_PROXY    = local.no_proxy
  }
  depends_on = [aws_eks_cluster.eks]
}
