data "aws_caller_identity" "current1" {}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
