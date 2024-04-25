#!/bin/bash

# Initialize a variable to keep track of any errors
errors_detected=0

# Check if AWS CLI, Terraform, Helm, and kubectl are installed
if ! command -v aws &>/dev/null; then
    echo "AWS CLI is not installed. Please install it."
    errors_detected=1
fi

if ! command -v terraform &>/dev/null; then
    echo "Terraform is not installed. Please install it."
    errors_detected=1
fi

if ! command -v helm &>/dev/null; then
    echo "Helm is not installed. Please install it."
    errors_detected=1
fi

if ! command -v kubectl &>/dev/null; then
    echo "kubectl is not installed. Please install it."
    errors_detected=1
fi

# Ensure you can access AWS
aws sts get-caller-identity >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Cannot access AWS. Please check your credentials."
    errors_detected=1
fi

# Verify that you have full access to EKS
kubectl get all --all-namespaces >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "You do not have full access to EKS. Please check your permissions."
    errors_detected=1
fi

# Check if Docker is installed and running
if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install it."
    errors_detected=1
elif ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start the Docker service."
    errors_detected=1
fi

# If no errors detected, print success message
if [ $errors_detected -eq 0 ]; then
    echo "All checks passed. Starting the script."

    # 获取脚本所在的目录
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    # 切换到脚本所在目录的上一级
    cd "$script_dir/.."

    # 将当前工作目录保存到一个变量中
    root_dir=$(pwd)

    terraform init
    terraform plan -var-file="$root_dir/variables.tfvars"
    terraform apply -auto-approve -var-file="$root_dir/variables.tfvars"

    # Set Kube config so that you can use kubectl to access to eks cluster
    aws eks update-kubeconfig --name monitor-troubleshooting

    cd "$root_dir"/resource-management/init-es

    # have to turn on docker
    make secrets

    cd "$root_dir"/resource-management
    terraform init
    terraform plan -var-file="$root_dir/variables.tfvars"
    terraform apply -auto-approve -var-file="$root_dir/variables.tfvars"

else
    echo "Please fix the issues before proceeding."
fi
