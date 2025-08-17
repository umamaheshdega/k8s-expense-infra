resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkka/cUG413uq1KagqOBy0258Fnp5zdOaU1TBkF6Kgv1WmlQpzg44jC490q5gVoJg2IlOZtA2ssV18LT3t7HycnTiYnvlfjKn9Tl/LXAUtW6G3Pkx8B6mqBP3XEPnhoFMl1q5F5K1TA3QbbLkpL83hDrXDf1g558fLA7CM50IN8oFVllpSt2JDdd56X4afo1jkZ+YWuqk4UDBiWfz1SJ3PXXxotqBPwqQiT8VnjFzXLMS3WOLAOks/+epoJmYSjJhZcmJ4QAdJj39s0P95IUo8C1of3bJfyyUqGCHMr0KhDye+XFbVb5M3849nRl7pIZ0dtmJCG6XYLJ7qz4zffOT7HpY0Z0FfGJGBoNdnzEhQ6bjbImKlL4mQnGHXUbww0NGUMR7eCI6rZxYxZmIxHUdUVh5qkw0N3Qoc+GKMcD0BrlblSzboHFa5GUSgZxfsRq7Q7bTk6ce4+uRWg992ANtjaPCqgYGSd9LfXdqKv2vexCr0sRBsOGjCBKTptNBRne7pFToJCQ22fFpMRhkrhP5gNi87pT4zdLqsgjUcBy/zRcWFZrp6gl0l60KQaodVPqmgxVGqIM2HyzFMBy++pnxPy2SNst9ZcRf74fSZ+rNnTtNL05812NIgYa2ex6mc5/NBsS9BOB/nJfFrNCN+91n6PsvaMXpFOroiUIerNE6kOw== expense-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id
 #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    #  blue = {
    #   # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    #   #ami_type       = "AL2_x86_64"
    #   instance_types = ["m5.xlarge"]
    #   key_name = aws_key_pair.eks.key_name

    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    # } 
      green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    

      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}