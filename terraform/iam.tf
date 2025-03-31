resource "aws_iam_role" "eks-alb-ingress-controller" {
  name = "eks-alb-ingress-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role_policy.json  
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
  role       = aws_iam_role.eks-alb-ingress-controller.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# Define the IAM policy document for the AssumeRole policy
data "aws_iam_policy_document" "alb_controller_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    effect    = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}