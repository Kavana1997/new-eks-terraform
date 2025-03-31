//removing the plugin atthe time of cluster ceration because it need node to be created first
resource "aws_eks_addon" "example" {
  depends_on = [ module.eks_managed_node_group ]
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  cluster_service_cidr = module.eks.cluster_service_cidr
  name            = "eks-node"
  cluster_name    = module.eks.cluster_name
  cluster_version = "1.31"

  subnet_ids = module.vpc.private_subnets
 # cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  #vpc_security_group_ids            = [module.eks.node_security_group_id]
  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = ["t3.large"]
  capacity_type  = "SPOT"

  labels = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}