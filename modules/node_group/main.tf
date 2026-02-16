# resource "aws_iam_role" "node_role" {
#   name = "${var.cluster_name}-${var.node_group_name}-node-role"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "worker_node" {
#   role = aws_iam_role.node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "cni" {
#   role       = aws_iam_role.node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "ecr" {
#   role       = aws_iam_role.node_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_eks_node_group" "this" {
#   cluster_name    = var.cluster_name
#   node_group_name = var.node_group_name
#   node_role_arn   = aws_iam_role.node_role.arn
#   subnet_ids      = var.subnet_ids
#   instance_types = var.instance_types  

#   scaling_config {
#     desired_size = var.desired_size
#     max_size     = var.max_size
#     min_size     = var.min_size
#   }

#   ami_type = "AL2_x86_64"

#   update_config {
#   max_unavailable = 1
#   }


#   labels = var.labels

#   dynamic "taint" {
#     for_each = var.taints
#     content {
#         key = taint.value.key
#         value = taint.value.value
#         effect = taint.value.effect
#     }
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.worker_node,
#     aws_iam_role_policy_attachment.cni,
#     aws_iam_role_policy_attachment.ecr,
#   ]
#   tags = {
#     Env = var.environment
#   }  
# }



