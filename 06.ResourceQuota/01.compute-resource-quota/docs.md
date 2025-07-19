# 1 创建resourcequotas/compute-resource-quota-01对象
```
## 创建resourcequotas/compute-resource-quota-01对象
root@master01:~# kubectl apply -f 01.resourcequotas_compute-resource-quota-01.yaml  --dry-run=client
resourcequota/compute-resource-quota-01 created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 01.resourcequotas_compute-resource-quota-01.yaml
resourcequota/compute-resource-quota-01 created
root@master01:~# 

## 查看ns/lili对象的describe
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:            compute-resource-quota-01
  Resource         Used  Hard
  --------         ---   ---
  limits.cpu       0     16
  limits.memory    0     32Gi
  requests.cpu     0     16
  requests.memory  0     32Gi

No LimitRange resource.
```

# 2 创建pods/myapp01对象
```
## 创建pods/myapp01对象
root@master01:~# 
root@master01:~# kubectl apply -f 02.pods_myapp01.yaml --dry-run=client
pod/myapp01 created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 02.pods_myapp01.yaml
pod/myapp01 created
root@master01:~# 
root@master01:~# kubectl get -f 02.pods_myapp01.yaml
NAME      READY   STATUS    RESTARTS   AGE
myapp01   1/1     Running   0          5s
root@master01:~# 
root@master01:~# kubectl get -f 02.pods_myapp01.yaml  -o json | jq ".spec.containers[].name, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "15",
  "memory": "31Gi"
}


## 查看ns/lili的describe信息
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:            compute-resource-quota-01
  Resource         Used   Hard
  --------         ---    ---
  limits.cpu       15     16
  limits.memory    31Gi   32Gi
  requests.cpu     100m   16
  requests.memory  156Mi  32Gi

No LimitRange resource.
```

# 3 创建pods/myapp02对象
```
## 创建pods/myapp02对象 
root@master01:~# kubectl apply -f 03.pods_myapp02.yaml  --dry-run=client
pod/myapp02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.pods_myapp02.yaml 
Error from server (Forbidden): error when creating "03.pods_myapp02.yaml": pods "myapp02" is forbidden: exceeded quota: compute-resource-quota-01, requested: limits.cpu=15,limits.memory=31Gi, used: limits.cpu=15,limits.memory=31Gi, limited: limits.cpu=16,limits.memory=32Gi
root@master01:~#
```

# 4 清理环境
```
kubectl delete -f 01.resourcequotas_compute-resource-quota-01.yaml
kubectl delete -f 02.pods_myapp01.yaml
kubectl delete -f 03.pods_myapp02.yaml
```
