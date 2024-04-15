cd ..
cd resource-management
./remove.sh
terraform destroy -auto-approve
cd ..
terraform destroy -auto-approve