output "resource_prefix" {
  description = "resource prefix"
  value       = local.name
}

output "proxy_config" {
  description = "Proxy config"
  value       = "http://${var.username}:${var.password}@${aws_instance.public.private_ip}:3128"
}

output "ssh_public" {
  description = "ssh to public instance"
  value       = "ssh -o'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ubuntu@${aws_instance.public.public_ip}"
}

output "ssh_private" {
  description = "ssh to private instance"
  value       = "ssh -o'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -J ubuntu@${aws_instance.public.public_ip} ubuntu@${aws_instance.private.private_ip}"
}

output "ssh_nat" {
  description = "ssh to NAT instance"
  value       = "ssh -o'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ubuntu@${aws_instance.ec2_nat.public_ip}"
}

output "ssh_nodepool" {
  description = "ssh to private instance"
  value       = "ssh -o'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -J ubuntu@${aws_instance.public.public_ip} ec2-user@${data.aws_instance.nodepool.private_ip}"
}

output "get_kubeconfig" {
  value = "aws eks --region ${local.region} update-kubeconfig --name ${aws_eks_cluster.eks.name}"
}

output "get_issuerURL" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "eks_name" {
  value = aws_eks_cluster.eks.name
}

output "cidr" {
  value = aws_vpc.this.cidr_block
}

output "region" {
  value = local.region
}