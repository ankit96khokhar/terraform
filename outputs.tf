output "vpc_ids" {
  value = {
    for k, v in module.vpc :
    k => v.vpc_id
  }
}

output "private_subnet_ids" {
  value = {
    for k, v in module.vpc :
    k => v.private_subnet_ids
  }
}

output "public_subnet_ids" {
  value = {
    for k, v in module.vpc :
    k => v.public_subnet_ids
  }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

