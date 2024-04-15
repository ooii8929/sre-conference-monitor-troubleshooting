#!/bin/bash

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

