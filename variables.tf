variable "environment" {
    description = "Environment name (dev, staging or prod)"
    type = string
}

variable "tenant" {
    description = "Tenant name"
    type = string
}

variable "region" {
    description = "Region name"
    type = string
    default = "ap-south-1"
}

# variable "default_node_group_taints" {
#   type = list(object({
#     key = string
#     value = string
#     effect = string
#   }))
#   default = []
# }

# variable "vpc_cidr" {}
# variable "public_subnets" {}
# variable "private_subnets" {}
# variable "availability_zones" {}
# variable "cluster_name" {}
# variable "cluster_version" {}



# variable "services" {
#   type = object({
#     vpc = optional(map(object({
#       vpc_cidr = string
#     })))

#     eks = optional(map(object({
#       vpc_name   = string
#       version    = string
#       node_groups = map(object({
#         instance_types = list(string)
#         min            = number
#         max            = number
#         desired        = number
#       }))
#     })))
#   })
# }

variable "services" {
  type = map(any)
  default = {}
}

variable "admin_principal_arn" {}
variable "account_id" {}

# variable "node_instance_types" {
#   type = list(string)
# }
