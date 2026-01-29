resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  
}

resource "aws_eks_cluster" "this" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version = var.cluster_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }  

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name = var.cluster_name
    Env  = var.environment
  }  

  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.admin_principal_arn
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_principal_arn

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_entry" "platform_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.platform_admin.arn
}

resource "aws_eks_access_policy_association" "platform_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.platform_admin.arn
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "developer" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.developer.arn
}

resource "aws_eks_access_entry" "viewer" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.viewer.arn
}

resource "aws_eks_access_entry" "cicd" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.cicd.arn
}

#add ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"

  configuration_values = jsonencode({
    tolerations = [
      {
        key      = "dedicated"
        operator = "Equal"
        value    = "platform"
        effect   = "NoSchedule"
      }
    ]
  })
}
