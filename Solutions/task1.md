Task1 的任務主要目標是讓學員剛開始這個 Lab，能夠掌握使用 Terraform 部署 Application 到 EKS 的方法。

1. 從 https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit 得知有 parameters additionalFilters & additionalOutputs 能夠直接對 FluentBit 調整設定
2. 從 helm_release.tf 可以看到我們將變數 file 拉出來設定
3. 將 /Tasks/task1 的 filter ，補在 additionalFilters 後方
```
additionalFilters: |
  [FILTER]
      Name grep
      Match kube.*
      Regex message 404
```
4. 將 /Tasks/task1 的 output ，補在 additionalOutputs 後方
```
additionalOutputs: |
    [OUTPUT]
        Name            es
        Match           kube.*
        Host            elasticsearch-master.kube-system.svc.cluster.local
        Port            9200
        AWS_Auth        Off
        TLS             On
        tls.verify      On
        Retry_Limit     6
        HTTP_User       elastic
        HTTP_Passwd     vmVhOB4Pn0wRvQO6xEgj
        Index           ${local.project_name}-application-logs-%Y.%W
        tls.ca_file /usr/share/fluentbit/config/certs/elastic-certificate.pem
```

5. (承3 & 4) 將 /Tasks/task1 的 output ，寫在 helm_release.tf 也可以
```
resource "helm_release" "fluent_bit" {
  name       = "fluent_bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"

  set {
    name  = "additionalFilters"
    value = <<-EOT
        [FILTER]
            Name grep
            Match kube.*
            Regex message 404
    EOT
  }

 
  set {
    name  = "additionalOutputs"
    value = <<-EOT
        [OUTPUT]
            Name            es
            Match           kube.*
            Host            elasticsearch-master.kube-system.svc.cluster.local
            Port            9200
            AWS_Auth        Off
            TLS             On
            tls.verify      On
            Retry_Limit     6
            HTTP_User       elastic
            HTTP_Passwd     vmVhOB4Pn0wRvQO6xEgj
            Index           ${local.project_name}-application-logs-%Y.%W
            tls.ca_file /usr/share/fluentbit/config/certs/elastic-certificate.pem
    EOT
  }
 
}
```
6. Terraform apply 部署
```
cd resource-management
terraform apply -var-file="../variables.tfvars"
```
7. 藉由指令確認是否將 config 如預期的進行更改
```
kubectl -n kube-system describe configmap fluent-bit
```
