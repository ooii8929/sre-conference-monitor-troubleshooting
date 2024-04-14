

terraform {
  required_providers {
    # Terraform 0.13 and later
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      version = "~> 2.12.0"
      source  = "hashicorp/helm"
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

# init k8s authentication
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  config_path = pathexpand(var.kube_config)
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.project_name]
    command     = "aws"
  }
}

