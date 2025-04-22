# 1.应用01.deploy_myapp01.yaml
```
## 检查语法
kubectl apply -f 01.deploy_myapp01.yaml --dry-run=client

## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl apply -f 01.deploy_myapp01.yaml 
deployment.apps/myapp01 created

## 查看deploy/myapp01对象的NewReplicaSet
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili describe deploy/myapp01 | grep NewReplicaSet:
NewReplicaSet:   myapp01-64db45b8bd (4/4 replicas created)  
#
# 当前rs(NewReplicaSet)上有4个副本,4个存在,是否可用不知道
#

## 列出deploy/myapp01对象相关的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili get deploy/myapp01
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp01   0/4     4            0           64s
   # 
   # 均未就绪/可用
   #
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili get deploy/myapp01
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp01   4/4     4            4           2m20s
   #
   # 均已就绪/可用
   # 待其完成就绪后,再做后面的操作
   #  

```

# 2.另开一个xshell窗口,监视着所有的rs资源对象。
```
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m34s
光标在闪烁

```


# 3.应用 02.deploy_myapp01-change-labels.yaml 
```
## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl apply -f 02.deploy_myapp01-change-labels.yaml 
deployment.apps/myapp01 configured

## 从deploy/myapp01对象其描述信息中查看OldReplicaSet和NewReplicaSet
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili describe deploy/myapp01 | grep -Ew "OldReplicaSets:|NewReplicaSet"
OldReplicaSets:  <none>
NewReplicaSet:   myapp01-855dcbc755 (4/4 replicas created)
   #
   # 没有OldReplicaSet，因为已经将其缩放至0了
   # 其NewReplicaSet上，有4个副本,4个存在,是否可用不知道
   # 

## 列出deploy/myapp01对象的相关rs资源对象
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili get rs | grep myapp01
myapp01-64db45b8bd   0         0         0       3m27s
myapp01-855dcbc755   4         4         0       26s
    #
    # 其NewReplicaSet(855dcbc755)上面的4副本均未就绪/可用
    # 

## 其实这里的更新已经完成了(看其deploy/myapp01对象其描述信息中的events)
root@master01:~/tools/pod-controller/01.deployments/02.strategy-of-Recreate# kubectl -n lili describe deploy/myapp01 | grep -A 10000 "Events:"
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  8m39s  deployment-controller  Scaled up replica set myapp01-64db45b8bd to 4
  Normal  ScalingReplicaSet  2m53s  deployment-controller  Scaled down replica set myapp01-64db45b8bd to 0
  Normal  ScalingReplicaSet  2m52s  deployment-controller  Scaled up replica set myapp01-855dcbc755 to 4
```

# 4.在之前监视rs资源对象的xshell窗口中看其结果，并分析
```
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       3m2s

myapp01-64db45b8bd   0         4         4       5m46s
myapp01-64db45b8bd   0         4         4       5m46s
myapp01-64db45b8bd   0         0         0       5m46s
myapp01-855dcbc755   4         0         0       0s    # 直接被缩放至0
myapp01-855dcbc755   4         0         0       0s
myapp01-855dcbc755   4         4         0       0s    # 均未就绪

myapp01-855dcbc755   4         4         1       2m1s
myapp01-855dcbc755   4         4         2       2m1s
myapp01-855dcbc755   4         4         3       2m1s
myapp01-855dcbc755   4         4         4       2m11s  # 均已就绪

```

# 5.清理环境
```
kubectl delete -f .
```
