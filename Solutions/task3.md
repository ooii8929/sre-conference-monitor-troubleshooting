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
3. 發現 role 設定被改掉
```
 <has "master" .Values.roles>: error calling has: Cannot find has on type map
```
4. roles:
  - master
  - data
  - data_content
  - data_hot
  - data_warm
  - data_cold
  - ingest
  - ml
  - remote_cluster_client
  - transform

5. 
```
failed to create patch: The order in patch list:
│ [map[name:node.roles value:master,data,data_content,data_hot,data_warm,data_cold,ingest,ml,remote_cluster_client,transform,] map[name:ELASTIC_PASSWORD valueFrom:map[secretKeyRef:map[name:elasticsearch-master-credentials]]] map[name:ELASTIC_PASSWORD valueFrom:map[secretKeyRef:map[key:password name:elastic-credentials]]] map[name:xpack.security.enabled value:true] map[name:xpack.security.transport.ssl.enabled value:true] map[name:xpack.security.http.ssl.enabled value:true] map[name:xpack.security.transport.ssl.verification_mode value:certificate] map[name:xpack.security.transport.ssl.key value:/usr/share/elasticsearch/config/certs/tls.key] map[name:xpack.security.transport.ssl.certificate value:/usr/share/elasticsearch/config/certs/tls.crt] map[name:xpack.security.transport.ssl.certificate_authorities value:/usr/share/elasticsearch/config/certs/ca.crt] map[name:xpack.security.http.ssl.key value:/usr/share/elasticsearch/config/certs/tls.key] map[name:xpack.security.http.ssl.certificate value:/usr/share/elasticsearch/config/certs/tls.crt] map[name:xpack.security.http.ssl.certificate_authorities value:/usr/share/elasticsearch/config/certs/ca.crt]]
│  doesn't match $setElementOrder list:
│ [map[name:node.name] map[name:cluster.initial_master_nodes] map[name:node.roles] map[name:discovery.seed_hosts] map[name:cluster.name] map[name:network.host] map[name:ELASTIC_PASSWORD] map[name:xpack.security.enabled] map[name:xpack.security.transport.ssl.enabled] map[name:xpack.security.http.ssl.enabled] map[name:xpack.security.transport.ssl.verification_mode] map[name:xpack.security.transport.ssl.key] map[name:xpack.security.transport.ssl.certificate] map[name:xpack.security.transport.ssl.certificate_authorities] map[name:xpack.security.http.ssl.key] map[name:xpack.security.http.ssl.certificate] map[name:xpack.security.http.ssl.certificate_authorities] map[name:ELASTIC_PASSWORD]]
```

5. "message": "Authentication of [elastic] was terminated by realm [reserved] - failed to authenticate user [elastic]"


"message": "failed to perform indices:data/write/bulk[s] on replica [.kibana_task_manager_7.17.3_001][0], node[t7fltlWEQmWcrRPXID5cag], [R], s[STARTED], a[id=OXxNj9-ATMCOE6cr8xA2wA], failure RemoteTransportException[[elasticsearch-master-1][10.0.2.41:9300][indices:data/write/bulk[s][r]]]; nested: ElasticsearchSecurityException[action [indices:data/write/bulk[s][r]] is unauthorized for user [elastic] with effective roles [superuser] on restricted indices [.kibana_task_manager_7.17.3_001], this action is granted by the index privileges [create_doc,create,delete,index,write,all]];


kibana 
image_tag remove

回推當時舊版的 Cert 建立方式，我們查到 Makefile 內有重複的建立。
4. 
