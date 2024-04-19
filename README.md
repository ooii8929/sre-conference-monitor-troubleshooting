# SRE Conference Lab - Learn how to deploy and upgrade a logs system

此 Lab 是為了讓剛進入職場的 SRE 工程師能夠快速掌握 Terraform 及 EFK debug 流程而設計的。Lab 中模擬作者實際在職場上遇到必須將 EFK 進行升級時遇到的問題復現出來。其中包含了
20% Terrform 應用
20% EFK debug 
30% EKS TLS 概念
30% 升級時注意事項

## Prerequisites

You can use ./utilities/check_requirements.sh to check if your settings match the lab requirements.

1. Check if you have installed AWS CLI, Terraform, Helm, and kubectl.
2. Ensure you can access AWS.
3. Verify that you have full access to EKS.
4. docker!!!!!


## Lab infrastructure and deploy process introduce
1. Below is the infrastructure
```
 tree -L 2
.
├── README.md
├── ec2.tf
├── eks.tf
├── main.tf
├── network.tf
├── utilities
│   ├── destroy.sh
│   ├── init.sh
│   └── remove.sh
├── resource-management
│   ├── data.tf
│   ├── helm_release.tf
│   ├── init-es
│   ├── provider.tf
│   ├── secret.yaml
│   ├── values
│   └── variables.tf
└── variables.tf


```
1. The root folder is for deploying EKS infrastructure and VPC network.
2. The resource-management folder is for deploying applications, such as Elasticsearch and Kibana.


## Initialize the lab

1. Rewrite the "owner" and "region" variable tag in the `variables.tf` file.
2. Run the following script file, which will build a new EKS cluster and deploy the applications required for the lab:

```
./init.sh
or
AWS_PROFILE=test ./init.sh
```


## TASK 1: Learn how to deploy Fluent Bit configuration using Terraform

### Your target

Use the following command to check if the Fluent Bit configuration is set to send logs to Elasticsearch. The lab has already provided the necessary configuration settings in `/tasks/task1.md`.

```
kubectl -n kube-system describe configmap fluent-bit
```

#### Update new setting to EKS with terraform.( the var-file parameter is important )
```
cd resource-management
terraform apply -var-file="../variables.tfvars"
```

ref: 
1. artifacthub-elasticsearch[https://artifacthub.io/packages/helm/elastic/elasticsearch]
2. artifacthub-fluentbit[https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit]

## TASK 2: Learn how to debug the logs system

### Your target

There are no data displayed in Kibana, which is not correct. 

Please check the network, logs, and settings to find out and ensure Kibana receives data from the logs-generator and filters only to display 404 errors.

Below is the port-forward command that can expose Kibana, and you can connect to it at `https://localhost:8080`:

```
kubectl -n kube-system port-forward <kibana pod name> 8080:5601
```

### Check Points
1. Only 404 errors can be found in Kibana.

## Task 3: Learn how to deprecated the outdated technology/config

### Your target
1. The current ElasticSearch and kibana version is 7.17.3. It is recommended to upgrade it to 8.5.1.
2. An important reminder for ElasticSearch version 8.5.1 is that certificates can be auto-created. Therefore, you may need to adjust some settings related to TLS connections.

### Check Points
1. By using the command `helm list -n kube-system`, you can see that both ElasticSearch and Kibana versions are 8.5.1.

## Clean up the lab
```
./destroy.sh
or
AWS_PROFILE=<profile> ./destroy.sh
```

## Other reminders

Sometimes when you rebuild Elasticsearch, you may encounter the "context deadline exceeded" error. This is because when you rebuild ES, it will retain the old Persistent Volume Claim (PVC), which can cause the rebuild process to fail. If you encounter this problem, please run the `/resource-management/remove.sh` script file, which will delete the dependent deprecated resources.