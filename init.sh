terraform init
terraform apply -auto-approve
cd resource-management
terraform init
terraform apply -auto-approve

# Set Kube config so that you can use kubectl to access to eks cluster
aws eks update-kubeconfig --name  monitor-troubleshooting