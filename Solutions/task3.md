Task3 的任務主要目標是讓學員知道今天面臨版本升級，會有很多舊的沒必要的設定已經被新版本做掉。如果直接引用新版設定，將會使程式碼相當簡潔。這次ElastiCloud升級8，官方幫我們將 TLS 連線做掉了。故原本很多需要的設定都可以移除。

1. 從官方文件的 value 比較，我們發現多了 createCert[https://artifacthub.io/packages/helm/elastic/elasticsearch/7.17.3?modal=values&compare-to=8.5.1]
2. 從 Lab 一開始的教學，我們得知 ElasticSearch 的 Cert 會關聯到 kibana 跟 fluent bit 的 TLS 設定。
3. 首先將 ElasticSearch 升級至8.5.1
```
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"
  namespace  = "kube-system"
  values = [
    file("./values/elasticsearch/value.yaml")
  ]
}
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "8.5.1"
  ...
}
```
3. 回推當時舊版的 Cert 建立方式，我們查到 Makefile 內有重複的建立。
4. 
