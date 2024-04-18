Task2 的任務主要目標是讓學員知道 EFK logs 沒有正常被傳輸時，應該如何 debug，這篇我們埋了兩個階段的錯誤，第一個是 filter 抓錯。Filter 是將 input 進來的 logs 再進行篩選的一層 layer，正常來說，我們應該要從 input 觀察 logs 正確是長怎樣，然後再進行 filter，只是如果你是經手專案，很容易就將config直接複製貼上(正如我們第一題的狀況一樣)。為了確認 input - filter - output 是否有正常運行，我們可以借用官網的 local output 的方式，確認在排除因為output連線、驗證等問題的狀況外，logs 是否有正常產出。第二個難題是儘管 output 有正確出來，但卻傳不到 elasticSearch，當我們遇到類似問題，最好的方式就是找出 logs，但預設的 logs 沒能提供足夠的資訊給我們。所以我們要善用官方提供的 trace error 參數。

1. 使用 'kubectl -n kube-system port-forward <pod name> 8080:5601' 進行對外曝光連線
2. 在瀏覽器打開 'https://localhost:8080/'，並從 Makefile 內找到 password vmVhOB4Pn0wRvQO6xEgj 進行登入。
3. 可以看到畫面提到你可以將 data 送進來。這代表 data 沒有成功送到 elastic Search
2. 為了找出原因
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
