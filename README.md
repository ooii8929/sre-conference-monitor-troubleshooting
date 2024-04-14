# SRE Conference Lab - Learn how to deploy and upgrade a logs system

## Prerequisites

1. Check if you have installed AWS CLI, Terraform, Helm, and kubectl.
2. Ensure you can access AWS.
3. Verify that you have full access to EKS.

## Lab infrastructure and deploy process introduce
1. 

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
kubectl -n kube-system describe configmap aws-cloudwatch-logs-aws-for-fluent-bit
```

## TASK 2: Learn how to debug the logs system

### Your target

There are no data displayed in Kibana, which is not correct. Please check the network, logs, and settings to find out and ensure Kibana receives data from the logs-generator and filters only to display 404 errors.

Below is the port-forward command that can expose Kibana, and you can connect to it at `http://localhost:8080`:

```
kubectl -n kube-system port-forward <kibana pod name> 8080:5601
```

## Clean up the lab

```
./destroy.sh
or
AWS_PROFILE=<profile> ./destroy.sh
```

## Other reminders

Sometimes when you rebuild Elasticsearch, you may encounter the "context deadline exceeded" error. This is because when you rebuild ES, it will retain the old Persistent Volume Claim (PVC), which can cause the rebuild process to fail. If you encounter this problem, please run the `/resource-management/remove.sh` script file, which will delete the dependent deprecated resources.