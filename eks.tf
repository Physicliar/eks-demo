module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.name}-cluster"
  kubernetes_version = "1.33"

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  # EKS Addons
  addons = {
    coredns = {
      most_recent_version = true
    }
    eks-pod-identity-agent = {
      before_compute      = true
      most_recent_version = true
    }

    amazon-cloudwatch-observability = {
      most_recent_version = true
    }

    kube-proxy = {
      most_recent_version = true
    }
    vpc-cni = {
      before_compute      = true
      most_recent_version = true
    }

  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    green = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  tags = local.tags
}
