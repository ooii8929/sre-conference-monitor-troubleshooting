module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.1"

  cluster_name                   = local.project_name
  cluster_version           = "1.27"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  create_cloudwatch_log_group = true

  cluster_endpoint_public_access  = true

  authentication_mode = "API_AND_CONFIG_MAP"

  # create_iam_role = true

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 3


      iam_role_additional_policies = {
        additional = aws_iam_policy.additional.arn
      }

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  } 

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = { most_recent = true } 
  }


}


resource "aws_iam_policy" "additional" {
  name        = "example-policy"
  description = "Example policy to allow EBS volume management for EKS managed node group"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:DescribeInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "logs:*"
        ],
        "Resource": "*"
      }
    ]
  })
}