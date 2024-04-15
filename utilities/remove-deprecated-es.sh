helm uninstall aws-cloudwatch-logs -n kube-system
helm uninstall kibana -n kube-system
helm uninstall elasticsearch -n kube-system
kubectl delete serviceaccount post-delete-kibana-kibana -n kube-system
kubectl delete serviceaccount pre-install-kibana-kibana -n kube-system
kubectl delete configmap kibana-kibana-helm-scripts -n kube-system
kubectl delete secrets kibana-kibana-es-token -n kube-system
kubectl -n kube-system delete role pre-install-kibana-kibana
kubectl -n kube-system delete role post-delete-kibana-kibana
kubectl -n kube-system delete rolebindings pre-install-kibana-kibana
kubectl -n kube-system delete rolebindings post-delete-kibana-kibana
kubectl -n kube-system delete job pre-install-kibana-kibana
kubectl -n kube-system delete job post-delete-kibana-kibana
kubectl delete rolebindings pre-install-kibana-kibana
kubectl delete rolebindings post-delete-kibana-kibana
kubectl -n kube-system delete pvc elasticsearch-master-elasticsearch-master-0
kubectl -n kube-system delete pvc elasticsearch-master-elasticsearch-master-1