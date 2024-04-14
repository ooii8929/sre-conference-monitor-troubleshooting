terraform {

  required_providers {
    aws = {
      version = ">= 5.37.0"
      source  = "hashicorp/aws"
    }
    helm = {
      version = "~> 2.12.0"
      source  = "hashicorp/helm"
    }
    kubernetes = {
      version = "~> 2.26.0"
      source  = "hashicorp/kubernetes"
    }
    random = {
      version = "~> 3.6.0"
      source  = "hashicorp/random"
    }
    tls = {
      version = "~> 4.0.5"
      source  = "hashicorp/tls"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
    default_tags {
        tags = {
            Owner     = var.owner
            Terraform = "true"
        }
    }
}



provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.cluster.endpoint, "")
  cluster_ca_certificate = base64decode(try(data.aws_eks_cluster.cluster.certificate_authority[0].data, ""))
  token                  = try(data.aws_eks_cluster_auth.cluster.token, "")
}

provider "helm" {
  kubernetes {
    host                   = try(data.aws_eks_cluster.cluster.endpoint, "")
    cluster_ca_certificate = base64decode(try(data.aws_eks_cluster.cluster.certificate_authority[0].data, ""))
    token                  = try(data.aws_eks_cluster_auth.cluster.token, "")
  }
}
