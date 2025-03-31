provider "aws" {
  region = "us-east-1"
  
}
terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = ">=2.11.0"  # Use the latest version available
    }
  }

  backend "s3" {
    region = "us-east-1"
    bucket = "devops4solutions-terraform"
    key    = "eks_cluster_3.tfstate"
  }
}