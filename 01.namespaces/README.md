# 1.namespaces资源的介绍
```
namespaces资源(简写ns)是kubernetes中的标准资源(只要安装好kubernetes后就有)。
namespaces资源可实例化出多个对象(例如：ns/dev-wyc，ns test-wyc wyc)。

kubernetes中的所有resources(标准的、使用operater扩展kubernetes时所添加的)可分为:
  namespace级别
    用 kubectl api-resources --namespaced=true 列出相关resources
    注 这些resources的API规范中其metadata.namespace字段是必选,指定所属ns资源对象
    
  非namespace级别(也称cluster级别)
    用 kubectl api-resources --namespaced=false 列出相关resources
    注 这些resources的API规范可能会有metadat.namespace字段,你指定ns资源对象也没用

那么namespace级别的resources所实例化出来的对象就得放在ns资源对象(namespaces资源实例化出的对象)中。
```

# 2.kubectl工具创建ns资源对象
```
# kubectl create namespace uat-wyc
# kubectl create ns        uat-wyc
  #
  # 命令行直接创建ns资源对象
  # 不建议这样做
  # 因为在创建任何资源对象时,我们应该使用manifests
  #

kubectl create namespace uat-wyc --dry-run=client -o yaml >./ns_uat-wyc.yaml
  #
  # 命令行快速生成ns资源对象的manifests,并保存于一个文件中。
  # 命令行无法指定ns/uat-wyc对象的相应label(不是必须的,可命令行添加)。
  # 但我们可以去修改其manifests(ns_uat-wyc.yaml)。
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


# -->列出已知的多个资源对象
kubectl get ns/dev-wyc ns/test-wyc ns/uat-wyc ns/wyc
    # 
    # 这种访问还可以掺杂着其它资源对象，例如：
    # kubectl get ns/dev-wyc ns/test-wyc ns/uat-wyc ns/wyc  deploy/myapp
    # 
kubectl get ns dev-wyc test-wyc uat-wyc wyc 
    #
    # 这种方式后面其ns后面的均得是ns资源对象
    #
kubectl get ns -l proj=wyc
    #
    # 这种方式列出所有ns资源对象后,再根据labels进行过滤
    #  
```

# 4.相关ns资源对象的删除
```
ns资源对象删除后，其里面的相关资源对象(namespace级别资源实例化出来的对象)也会被删除,所以是很危险的。
避免：
  01：不要将ns资源对象的manifests放在其它资源对象其manifests中。
      (例如：deploy_myapp01.yaml中不要有所需要ns资源对象的manifests)
  02：不要随意操作

如果：
  平时在创建资源对象时应该使用manfiests,而不是命令行直接创建。
     这样就能够使用相应的manfiests快速再进行创建
     但恢复的时间还是有点慢
  之前应该要对kubernetes做了逻辑备份
     这样在恢复时速度相对要快一些

删除命令：
  kubectl delete ns/<ns资源对象>  
  kubectl delete ns/<ns资源对象> ns/<ns资源对象>
  
  kubectl delete ns <ns资源对象>
  kubectl delete ns <ns资源对象> <ns资源对象>
```

# 5.扩展
```
查看某个ns资源对象中有哪些资源对象
  注意：
    kubectl -n <Ns资源对象>  get all 是不能完全列出里面的所有资源对象的
  可用：
    kubectl api-resources --verbs=list --namespaced=true -o name
      #
      # 列出namespace级别的resources，且只显示name
      #
    kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl -n <ns资源对象>  get --show-kind  --ignore-not-found | sed '/^NAME/'d | awk -F " " '{print $1}' 
```
