variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

# variable "public_subnets" {
#   description = "Public subnet CIDRs"
#   type        = list(string)
# }

# variable "private_subnets" {
#   description = "Private subnet CIDRs"
#   type        = list(string)
# }

# variable "availability_zones" {
#   description = "AZs to use"
#   type        = list(string)
# }

variable "cluster_name" {
  description = "EKS cluster name (for subnet tags)"
  type        = string
}

variable "environment" {
  type = string
}
