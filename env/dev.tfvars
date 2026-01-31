environment = "dev"
region = "ap-south-1"

cluster_name = "eks-dev"
cluster_version = "1.30"

vpc_cidr = "10.0.0.0/16"

# availability_zones = [
#   "ap-south-1a",
#   "ap-south-1b"
# ]

# public_subnets = [
#   "10.0.1.0/24",
#   "10.0.2.0/24"
# ]

# private_subnets = [
#   "10.0.101.0/24",
#   "10.0.102.0/24"
# ]

admin_principal_arn = "arn:aws:iam::907793002691:user/admin"
account_id = "907793002691"

default_node_group_taints = [
    {
        key    = "dedicated"
        value  = "platform"
        effect = "NO_SCHEDULE"
    }
]

node_instance_types = ["c7i-flex.large"]
