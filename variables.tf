variable "environment" {
    description = "Environment name (dev, staging or prod)"
    type = string
}

variable "region" {
    description = "Region name"
    type = string
    default = "ap-south-1"
}

variable "default_node_group_taints" {
  type = list(object({
    key = string
    value = string
    effect = string
  }))
  default = []
}

variable "vpc_cidr" {}
# variable "public_subnets" {}
# variable "private_subnets" {}
# variable "availability_zones" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "admin_principal_arn" {}
variable "account_id" {}

variable "node_instance_types" {
  type = list(string)
}
