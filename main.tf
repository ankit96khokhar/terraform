# module "vpc" {
#   source = "./modules/vpc"

#   vpc_cidr           = var.vpc_cidr
#   # public_subnets     = var.public_subnets
#   # private_subnets    = var.private_subnets
#   # availability_zones = var.availability_zones
#   cluster_name       = var.cluster_name
#   environment        = var.environment
# }

module "vpc" {
  for_each    = try(var.services.vpc, {})
  source      = "./modules/vpc"
  vpc_name    = each.key
  vpc_cidr    = each.value.vpc_cidr
  environment = var.environment
}

locals {
  state_bucket = "ankit-eks-tf-state-${var.environment}"
  vpc_name = var.services.eks[var.cluster_name].vpc_name
}

data "terraform_remote_state" "vpc_info" {
  backend = "s3"

  config = {
    bucket = local.state_bucket
    key = "${var.tenant}/${var.environment}/${var.region}/terraform.tfstate"
    region = var.region
  }
}

module "eks" {
  # for_each = try(var.services.eks, {})
  source   = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.services.eks[var.cluster_name].version
  # node_groups         = each.value.node_groups
  environment         = var.environment
  vpc_id              = data.terraform_remote_state.vpc_info.outputs.vpc_ids[local.vpc_name]
  private_subnet_ids  = data.terraform_remote_state.vpc_info.outputs.private_subnet_ids[local.vpc_name]
  admin_principal_arn = var.admin_principal_arn
  account_id          = var.account_id
}

locals {
  dynamodb_enabled = try(var.services.dynamodb.enabled, false)
  dynamodb_config  = try(var.services.dynamodb.config, {})
}

module "dynamodb" {
  for_each = local.dynamodb_enabled ? local.dynamodb_config : {}

  source = "./modules/dynamodb"

  table_name   = each.value.table_name
  billing_mode = try(each.value.billing_mode, "PAY_PER_REQUEST")

  tags = {
    Project     = "eks-fleet-orchestrator"
    Environment = var.environment
  }
}





# module "eks_bootstrap" {
#   for_each = module.eks
#   source   = "./modules/eks-bootstrap"

#   cluster_name               = each.value.cluster_name
#   cluster_endpoint           = each.value.cluster_endpoint
#   cluster_ca_certificate     = each.value.cluster_certificate_authority
#   oidc_provider_arn          = each.value.oidc_provider_arn
#   oidc_provider_url          = each.value.oidc_provider_url

#   vpc_id                     = each.value.vpc_id
#   region                     = var.region
#   environment                = var.environment
#   admin_principal_arn        = var.admin_principal_arn
#   account_id                 = var.account_id
# }


# module "node_group" {
#   source = "./modules/node_group"

#   cluster_name = var.services["eks"]["cluster_name"]
#   node_group_name = var.services["eks"]["node_groups"]["node_group_name"]
#   subnet_ids = module.vpc.private_subnet_ids
#   instance_types = var.services["eks"]["node_groups"]["instance_types"]
#   desired_size = var.services["eks"]["node_groups"]["desired"]
#   min_size = var.services["eks"]["node_groups"]["min"]
#   max_size = var.services["eks"]["node_groups"]["max"]
#   environment = var.environment

#   labels = {
#     role = "general"
#   }

# }
