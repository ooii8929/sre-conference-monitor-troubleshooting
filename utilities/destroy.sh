#!/bin/bash

# 获取脚本所在的目录
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 切换到脚本所在目录的上一级
cd "$script_dir/.."

# 将当前工作目录保存到一个变量中
root_dir=$(pwd)

"$script_dir"/remove-deprecated-es.sh

cd "$root_dir"/resource-management
terraform destroy -auto-approve -var-file="$root_dir/variables.tfvars"
cd "$root_dir"
terraform destroy -auto-approve -var-file="$root_dir/variables.tfvars"