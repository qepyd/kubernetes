# 1.namespaces的介绍
```
namespaces资源(简写ns)是kubernetes中的标准资源(只要安装好kubernetes后就有)。
namespaces资源可实例化出多个对象(例如：ns/dev-wyc、ns test-wyc wyc)。
```

# 2.kubectl工具快速编写ns资源对象的manifests
```
kubectl create namespace uat-wyc --dry-run=client -o yaml >/ns_uat-wyc.yaml
  #
  # 命令行无法指定ns/uat-wyc对象的相应label
  # 但我们可以去修改其manifests(ns_uat-wyc.yaml)
  #
```

# 3.应用相关的manifests
```
# -->检查语法
kubectl apply -f ./ns_dev-wyc.yaml --dry-run=client
# -->应用manifests
kubectl apply -f ./ns_dev-wyc.yaml
# -->列出manifests中的相关资源对象
kubectl get   -f ./ns_dev-wyc.yaml
# -->列出ns/dev-wyc对象
kubectl get   ns/dev-wyc
# -->列出所有的ns资源对象,并根据labels过滤，且显示所有labels
kubectl get   ns -l env=dev  --show-labels

kubectl apply -f ./ns_test-wyc.yaml --dry-run=client
kubectl apply -f ./ns_test-wyc.yaml
kubectl get   -f ./ns_test-wyc.yaml
kubectl get   ns/test-wyc
kubectl get   ns -l env=test  --show-labels


kubectl apply -f ./ns_uat-wyc.yaml --dry-run=client
kubectl apply -f ./ns_uat-wyc.yaml
kubectl get   -f ./ns_uat-wyc.yaml
kubectl get   ns/uat-wyc
kubectl get   ns -l kubernetes.io/metadata.name=uat-wyc  --show-labels


kubectl apply -f ./ns_wyc.yaml --dry-run=client
kubectl apply -f ./ns_wyc.yaml
kubectl get   -f ./ns_wyc.yaml
kubectl get   ns/wyc
kubectl get   ns -l env=prod --show-labels
```

# 4.相关ns资源对象的删除
```
kubernetes中的所有resources(标准、使用operater扩展kubernetes时所添加的)可分为:
  namespace级别
  非namespace级别(也称cluster级别)
  可用 kubectl api-resources 看结果的NAMESPACED字段。

那么namespace级别的resources就得放在ns资源对象(namespaces资源实例化出的对象)中。
```
