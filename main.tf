module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  cluster_name       = var.cluster_name
  environment        = var.environment
}

# module "eks" {
#   source = "./modules/eks"

#   cluster_name        = var.cluster_name
#   cluster_version     = var.cluster_version
#   environment         = var.environment
#   vpc_id              = module.vpc.vpc_id
#   private_subnet_ids  = module.vpc.private_subnet_ids
#   admin_principal_arn = var.admin_principal_arn
#   account_id = var.account_id
# }

# module "default_node_group" {
#   source = "./modules/node-group"

#   cluster_name = module.eks.cluster_name
#   node_group_name = "default"
#   subnet_ids = module.vpc.private_subnet_ids
#   instance_types = var.node_instance_types
#   desired_size = 1
#   min_size = 1
#   max_size = 2
#   environment = var.environment

#   labels = {
#     role = "general"
#   }

# }
