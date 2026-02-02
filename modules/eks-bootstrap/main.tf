# # resource "aws_iam_role" "alb_controller" {
# #   name = "${var.cluster_name}-alb-controller"

# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [{
# #       Effect = "Allow"
# #       Principal = {
# #         Federated = var.oidc_provider_arn
# #       }
# #       Action = "sts:AssumeRoleWithWebIdentity"
# #       Condition = {
# #         StringEquals = {
# #           "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
# #           "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
# #         }
# #       }
# #     }]
# #   })
# # }

# # resource "helm_release" "aws_lb_controller" {
# #   name       = "aws-load-balancer-controller"
# #   namespace  = "kube-system"
# #   repository = "https://aws.github.io/eks-charts"
# #   chart      = "aws-load-balancer-controller"
# #   version    = "1.7.1"

# #   values = [jsonencode({
# #     clusterName = var.cluster_name
# #     region      = var.region
# #     vpcId       = var.vpc_id

# #     serviceAccount = {
# #       create = true
# #       name   = "aws-load-balancer-controller"
# #       annotations = {
# #         "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
# #       }
# #     }
# #   })]
# # }

# # provider "kubernetes" {
# #   host                   = var.cluster_endpoint
# #   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

# #   exec {
# #     api_version = "client.authentication.k8s.io/v1beta1"
# #     command     = "aws"
# #     args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
# #   }
# # }

# # resource "kubernetes_namespace" "argocd" {
# #   metadata {
# #     name = "argocd"
# #   }
# # }

# # resource "helm_release" "argocd" {
# #   name       = "argocd"
# #   namespace  = "argocd"
# #   repository = "https://argoproj.github.io/argo-helm"
# #   chart      = "argo-cd"
# # }





# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   namespace  = kubernetes_namespace.argocd.metadata[0].name
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   version    = "6.7.12"

#   values = [jsonencode({
#     server = {
#       service = {
#         type = "ClusterIP"
#       }
#     }
#   })]

#   depends_on = [helm_release.aws_lb_controller, kubernetes_namespace.argocd]
# }

# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   namespace  = "kube-system"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   version    = "3.12.1"

#   values = [jsonencode({
#     args = [
#       "--kubelet-insecure-tls"
#     ]
#   })]
# }

# resource "aws_iam_role" "alb_controller" {
#   name = "${var.services["eks"]["cluster_name"]}-alb-controller"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = module.eks.oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format(
#             "%s:sub",
#             replace(module.eks.oidc_provider_url, "https://", "")
#           ) = "system:serviceaccount:kube-system:aws-load-balancer-controller"

#           format(
#             "%s:aud",
#             replace(module.eks.oidc_provider_url, "https://", "")
#           ) = "sts.amazonaws.com"
#         }
#       }
#     }]
#   })
# }


# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.7.1"

#   values = [jsonencode({
#     clusterName = module.eks.cluster_name
#     region      = var.region
#     vpcId       = module.vpc.vpc_id

#     serviceAccount = {
#       create = true
#       name   = "aws-load-balancer-controller"
#       annotations = {
#         "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
#       }
#     }
#   })]

#   depends_on = [aws_iam_role.alb_controller]
# }

# resource "aws_iam_role" "ebs_csi" {
#   name = "${var.services["eks"]["cluster_name"]}-ebs-csi"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = module.eks.oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format(
#             "%s:sub",
#             replace(module.eks.oidc_provider_url, "https://", "")
#           ) = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#         }
#       }
#     }]
#   })
# }


# resource "aws_iam_role_policy_attachment" "ebs_csi" {
#   role       = aws_iam_role.ebs_csi.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# resource "helm_release" "ebs_csi" {
#   name       = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   version    = "2.30.0"

#   atomic          = true
#   wait            = true
#   timeout         = 600
#   cleanup_on_fail = true

#   values = [jsonencode({
#     controller = {
#       serviceAccount = {
#         create = true
#         name   = "ebs-csi-controller-sa"
#         annotations = {
#           "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi.arn
#         }
#       }
#     }
#   })]

#   depends_on = [
#     aws_iam_role_policy_attachment.ebs_csi
#   ]
# }

# #Karpenter
# resource "aws_iam_role" "karpenter_controller" {
#   name = "${var.services["eks"]["cluster_name"]}-karpenter-controller"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = module.eks.oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format(
#             "%s:sub",
#             replace(module.eks.oidc_provider_url, "https://", "")
#           ) = "system:serviceaccount:karpenter:karpenter"

#           format(
#             "%s:aud",
#             replace(module.eks.oidc_provider_url, "https://", "")
#           ) = "sts.amazonaws.com"
#         }
#       }
#     }]
#   })
# }

# resource "aws_iam_policy" "karpenter_controller" {
#   name        = "${var.services["eks"]["cluster_name"]}-karpenter-controller"
#   description = "IAM policy for Karpenter controller"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [

#       # EC2 actions (core)
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateLaunchTemplate",
#           "ec2:DeleteLaunchTemplate",
#           "ec2:DescribeLaunchTemplates",
#           "ec2:DescribeInstances",
#           "ec2:DescribeInstanceTypes",
#           "ec2:DescribeInstanceTypeOfferings",
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeImages",
#           "ec2:RunInstances",
#           "ec2:TerminateInstances",
#           "ec2:CreateFleet",
#           "ec2:DescribeSpotPriceHistory",
#           "ec2:DescribeKeyPairs",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeTags"
#         ]
#         Resource = "*"
#       },

#       # IAM PassRole for node role
#       {
#         Effect = "Allow"
#         Action = "iam:PassRole"
#         Resource = aws_iam_role.karpenter_node.arn
#       },

#       # Pricing (needed for instance selection)
#       {
#         Effect = "Allow"
#         Action = "pricing:GetProducts"
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "karpenter_controller" {
#   role       = aws_iam_role.karpenter_controller.name
#   policy_arn = aws_iam_policy.karpenter_controller.arn
# }

# resource "aws_iam_role" "karpenter_node" {
#   name = "${var.services["eks"]["cluster_name"]}-karpenter-node"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "helm_release" "karpenter" {
#   name       = "karpenter"
#   namespace  = "karpenter"
#   chart      = "oci://public.ecr.aws/karpenter/karpenter"
#   version    = "1.0.6"

#   create_namespace = true

#   atomic          = true
#   wait            = true
#   timeout         = 600
#   cleanup_on_fail = true

#   values = [jsonencode({
#     serviceAccount = {
#       create = true
#       name   = "karpenter"
#       annotations = {
#         "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
#       }
#     }

#     settings = {
#       clusterName     = module.eks.cluster_name
#       clusterEndpoint = module.eks.cluster_endpoint
#     }
#   })]

#   depends_on = [
#     aws_iam_role_policy_attachment.karpenter_controller
#   ]
# }
