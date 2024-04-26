data "aws_eks_cluster" "cluster" {
  name = local.project_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.project_name
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.project_name]
  }
}
