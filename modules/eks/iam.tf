data "aws_iam_policy_document" "eks_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "platform_admin" {
  name = "${var.cluster_name}-platform-admin-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

resource "aws_iam_role_policy_attachment" "platform_admin" {
  role       = aws_iam_role.platform_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "developer" {
  name               = "${var.cluster_name}-developer"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

resource "aws_iam_role_policy_attachment" "developer" {
  role       = aws_iam_role.developer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "viewer" {
  name               = "${var.cluster_name}-viewer"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

resource "aws_iam_role" "cicd" {
  name               = "${var.cluster_name}-cicd"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}

resource "aws_iam_role_policy_attachment" "cicd" {
  role       = aws_iam_role.cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
