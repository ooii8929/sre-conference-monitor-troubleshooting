# Filter Config
```
[FILTER]
    Name grep
    Match kube.*
    Regex message 404
```


# Output Config
```
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


check endpoint
```
kubectl -n kube-system describe configmap aws-cloudwatch-logs-aws-for-fluent-bit
```