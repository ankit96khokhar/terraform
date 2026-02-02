output "vpc_id" {
    value = module.vpc.vpc_id
}

output "vpc_ids" {
  value = {
    for k, v in module.vpc:
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

output "eks_cluster_names" {
  value = {
    for k, v in module.eks :
    k => v.cluster_name
  }
}


output "eks_cluster_endpoints" {
  value = {
    for k, v in module.eks :
    k => v.cluster_endpoint
  }
}


output "eks_oidc_provider_arns" {
  value = {
    for k, v in module.eks :
    k => v.oidc_provider_arn
  }
}
