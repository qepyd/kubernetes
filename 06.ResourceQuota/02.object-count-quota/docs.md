# 1 创建resourcequota/object-count-quota-01对象
```
## 应用manifests
root@master01:~#
root@master01:~# kubectl apply -f 01.resourcequotas_object-count-quota-01.yaml --dry-run=client
resourcequota/object-count-quota-01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.resourcequotas_object-count-quota-01.yaml 
resourcequota/object-count-quota-01 created
root@master01:~#

## 列出资源对象
root@master01:~#
root@master01:~# kubectl -n lili get resourcequota/object-count-quota-01
NAME                         AGE   REQUEST     LIMIT
object-count-quota-01   23s   pods: 0/4   
root@master01:~#

## 查看其所属namespace的describe
root@master01:~#
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:     object-count-quota-01
  Resource  Used  Hard
  --------  ---   ---
  pods      0     4

No LimitRange resource.
root@master01:~#
``` 

# 2 验证对namespace的配额之针对pods资源对象数量
**创建deployments/myapp01对象**
```
## 应用manifests
root@master01:~#
root@master01:~# kubectl apply -f 02.deploy_myapp01.yaml  --dry-run=client
deployment.apps/myapp01 created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 02.deploy_myapp01.yaml 
deployment.apps/myapp01 created
root@master01:~#

## 列出deployments/myapp01对象
root@master01:~#
root@master01:~# kubectl  -n lili get deployments/myapp01
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp01   4/4     4            4           31s
root@master01:~#

## 列出deployments/myapp01对象相关的replicasets资源对象
root@master01:~#
root@master01:~# kubectl -n lili get replicasets | grep "^myapp01-"
myapp01-8b4cd49f5   4         4         4       81s
root@master01:~#

## 根据deployments/myapp01对象相关new replicaset资源对象列出Pod副本
root@master01:~#
root@master01:~# kubectl -n lili describe deployments/myapp01  | grep "NewReplicaSet:" | cut -d " " -f 4
myapp01-8b4cd49f5
root@master01:~#
root@master01:~# kubectl -n lili get pods | grep "^myapp01-8b4cd49f5"
myapp01-8b4cd49f5-4n5st   1/1     Running   0          7m14s
myapp01-8b4cd49f5-csmh5   1/1     Running   0          7m14s
myapp01-8b4cd49f5-pf5qh   1/1     Running   0          7m14s
myapp01-8b4cd49f5-v8qdl   1/1     Running   0          7m14s
root@master01:~#
```

**查看ns/lili名称空间的describe**
```
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:     object-count-quota-01
  Resource  Used  Hard
  --------  ---   ---
  pods      4     4

No LimitRange resource.
```

**创建deployments/myapp02对象**
```
## 应用manifests
root@master01:~#
root@master01:~# kubectl apply -f 03.deploy_myapp02.yaml  --dry-run=client
deployment.apps/myapp02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.deploy_myapp02.yaml 
deployment.apps/myapp02 created
root@master01:~#

## 列出相关资源对象
root@master01:~#
root@master01:~# kubectl get -f 03.deploy_myapp02.yaml
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp02   0/0     0            0           4s      # 此deployment/myapp02对象的副本是为1,但这里其READY为0/0。
root@master01:~#
root@master01:~# kubectl  -n lili get replicasets | grep "^myapp02"
myapp02-7fb9f5c457   0         0         0       100s
root@master01:~# 
root@master01:~# kubectl  -n lili get replicasets | grep "^myapp02-"
myapp02-7fb9f5c457   0         0         0       106s
root@master01:~# 
root@master01:~# kubectl  -n lili get pods | grep "^myapp02"
root@master01:~# 
```

**更新deployments/myapp01对象中其Pod模式中其myapp01容器的镜像**
```
## 更新deployments/myapp01对象的image
root@master01:~#
root@master01:~# kubectl -n lili  set image deployments/myapp01  myapp01=swr.cn-north-1.myhuaweicloud.com/library/nginx:1.17
deployment.apps/myapp01 image updated
root@master01:~#

## 列出ns/lili对象中所有deployments资源对象、replicas资源对象、pods资源对象
root@master01:~#
root@master01:~# kubectl  -n lili get deployments
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp01   3/4     2            3           30m     # 注意其READY字段
myapp02   1/1     1            1           12m     # 注意其READY字段
root@master01:~#
root@master01:~# kubectl  -n lili get replicasets
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-79dc8ccb8    4         2         2       9m27s
myapp01-8b4cd49f5    1         1         1       30m
myapp02-7fb9f5c457   1         1         1       13m
root@master01:~# 
root@master01:~# kubectl  -n lili get pods
NAME                       READY   STATUS    RESTARTS   AGE
myapp01-79dc8ccb8-hjc8k    1/1     Running   0          9m26s
myapp01-79dc8ccb8-j8fhh    1/1     Running   0          9m28s
myapp01-8b4cd49f5-pf5qh    1/1     Running   0          30m
myapp02-7fb9f5c457-d9n49   1/1     Running   0          7m37s
root@master01:~#
```

# 3 清理环境
```
kubectl delete -f  01.resourcequotas_object-count-quota-01.yaml 
kubectl delete -f  02.deploy_myapp01.yaml
kubectl delete -f  03.deploy_myapp02.yaml
```
