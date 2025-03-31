/*
1️⃣ Create an IAM Group (eks-admin-group)

This group will contain users who need admin access to EKS.
2️⃣ Create an IAM Role (k8s-admin-role)

Allows users in the eks-admin-group to assume this role for EKS admin tasks.
Trust policy ensures only eks-admin-group members can assume the role.
3️⃣ Create an IAM Policy (eks-assume-role-policy)

Grants sts:AssumeRole permission for the k8s-admin-role.
Attached to the eks-admin-group, allowing its users to assume the role.
4️⃣ Register IAM Role with EKS (aws_eks_access_entry)

Associates k8s-admin-role with the EKS cluster.
5️⃣ Attach EKS Admin Policy (aws_eks_access_policy_association)

Grants k8s-admin-role full EKS administrative access
*/
resource "aws_iam_group" "admin_group" {
  name = "eks-admin-group"
}
resource "aws_iam_role" "admin_role" {
    name = "eks-admin-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                      "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id
}:root"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "admin_permissions" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
# Create IAM Policy for AssumeRole
resource "aws_iam_policy" "eks_assume_role_policy" {
  name        = "eks-assume-role-policy"
  description = "Allows users in the group to assume the eks-admins-role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::936379345511:role/${aws_iam_role.admin_role.name}"
      }
    ]
  })
}

# Attach Policy to IAM Group
resource "aws_iam_group_policy_attachment" "attach_assume_role_policy" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.eks_assume_role_policy.arn
}

resource "aws_eks_access_entry" "example" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_role.admin_role.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.admin_role.arn
  access_scope {
    type       = "cluster"
  }
}



