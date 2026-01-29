output "cluster_name" {
  value = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "platform_admin_role_arn" {
  value = aws_iam_role.platform_admin.arn
}

output "developer_role_arn" {
  value = aws_iam_role.developer.arn
}

output "viewer_role_arn" {
  value = aws_iam_role.viewer.arn
}

output "cicd_role_arn" {
  value = aws_iam_role.cicd.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}