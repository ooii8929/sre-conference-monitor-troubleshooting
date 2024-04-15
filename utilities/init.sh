#!/bin/bash
cd ..

AWS_REGION="ap-northeast-1"
OWNER_NAME="ALVINLIN"

if [ "$(uname)" == "Linux" ] || [ "$(uname)" == "Darwin" ]; then
    echo "判斷為 Linux / MAC 環境"
    export AWS_DEFAULT_REGION=$AWS_REGION
    export TF_VAR_region=$AWS_REGION
    export TF_VAR_owner=$OWNER_NAME
# Windows
elif [ "$(expr substr $(uname -s) 1 9)" == "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    echo "判斷為 Windows 環境"
    SET AWS_DEFAULT_REGION=$AWS_REGION
    SET OWNER=$OWNER_NAME
else
    echo "未知操作系統，使用預設值"
    export AWS_DEFAULT_REGION=$AWS_REGION
    export TF_VAR_region=$AWS_REGION
    export TF_VAR_owner=$OWNER_NAME
fi

terraform init
terraform plan
terraform apply -auto-approve
cd resource-management/init-es
# have to turn on docker
make secrets
cd ..
terraform init
terraform plan
terraform apply -auto-approve

# Set Kube config so that you can use kubectl to access to eks cluster
aws eks update-kubeconfig --name monitor-troubleshooting

# kubectl apply -f ./values/elasticsearch/secret.yaml
