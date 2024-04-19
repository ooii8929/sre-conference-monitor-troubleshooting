resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.17.3"
  namespace  = "kube-system"
  values = [
    file("./values/elasticsearch/value.yaml")
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.3"
  namespace  = "kube-system"
  values = [
    file("./values/kibana/value.yaml")
  ]

  depends_on = [
    helm_release.elasticsearch
  ]

}


resource "helm_release" "fluent_bit" {
  name       = "fluent_bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.32"
  namespace  = "kube-system"

  values = [
    file("./values/fluentbit/value.yaml")
  ]

  set {
    name  = "rbac.pspEnabled"
    value = "false"
  }
  set {
    name  = "firehose.enabled"
    value = "false"
  }
  set {
    name  = "kinesis.enabled"
    value = "false"
  }
  
  depends_on = [
    helm_release.kibana
  ]
}

resource "helm_release" "log-generator" {
  name       = "log-generator"
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "log-generator"
  version    = "0.1.20"

  depends_on = [
    helm_release.fluent_bit
  ]
}

