## 1.部署应用(01.deploy_myapp01.yaml)
```
# 应用manifests
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl apply -f 01.deploy_myapp01.yaml
deployment.apps/myapp01 created

# 从deploy/myapp01对象的描述信息中查看NewReplicaSet是哪个rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-64db45b8bd (4/4 replicas created)

# 列出deploy/myapp01对象的所有rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili get rs | grep myapp01
myapp01-64db45b8bd   4         4         0       103s
   #
   # 均未就绪/可用
   # 要等其就绪/可用后,再做后面的操作
   #
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili get rs | grep myapp01
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m30s
   #
   # 均已就绪/可用
   # 可以做后面的操作了
   #

# 列出deploy/myapp01对象相关的Pod
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili get pods --show-labels | grep myapp01
myapp01-64db45b8bd-g9bf4   1/1     Running   0          2m30s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-lcsdw   1/1     Running   0          2m30s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-lhww9   1/1     Running   0          2m30s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-tbslp   1/1     Running   0          2m30s   app=myapp01,pod-template-hash=64db45b8bd
```


## 2.触发更新(02.deploy_myapp01-change-labels.yaml)
```
# 另开xshell窗口 watch rs其变化的说明
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m28s
光标在闪烁

# 应用maniefsts
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl apply -f 02.deploy_myapp01-change-labels.yaml
deployment.apps/myapp01 configured

# 从deploy/myapp01对象的描述信息中查看OldReplicaSet及NewReplicaSet
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili describe deploy/myapp01 | grep -E "OldReplicaSets:|NewReplicaSet:"
OldReplicaSets:  myapp01-64db45b8bd (3/3 replicas created)
NewReplicaSet:   myapp01-855dcbc755 (1/1 replicas created)

# 从watch rs其变化的来分析
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       3m48s
myapp01-855dcbc755   0         0         0       0s
myapp01-855dcbc755   0         0         0       0s
myapp01-64db45b8bd   3         4         4       4m1s
myapp01-855dcbc755   1         0         0       0s
myapp01-64db45b8bd   3         4         4       4m1s
myapp01-855dcbc755   1         0         0       0s
myapp01-64db45b8bd   3         3         3       4m1s  # <== 滚动更新第一轮：OldReplicaSet: 3(均可用)
myapp01-855dcbc755   1         1         0       1s    # <== 滚动更新第一轮：NewReplicaSet: 1(均不可用)
                                                       # <-- 是不是保证了"最少可用的Pod数 3"
myapp01-855dcbc755   1         1         1       2m1s  # <-- 是不是保证了"最大可用的Pod数 4(3 old pod + 1 new pod)",进入下一轮。
myapp01-64db45b8bd   2         3         3       6m2s
myapp01-64db45b8bd   2         3         3       6m2s
myapp01-855dcbc755   2         1         1       2m1s
myapp01-64db45b8bd   2         2         2       6m2s  # <== 滚动更新第二轮：OldReplicaSet: 2(均可用)
myapp01-855dcbc755   2         1         1       2m1s  
myapp01-855dcbc755   2         2         1       2m1s  # <== 滚动更新第二轮：NewReplicaSet: 2(1可用,1不可用)
                                                       # <-- 是不是保证了"最少可用Pod数 3"
myapp01-855dcbc755   2         2         2       4m12s # <-- 是不是保证了"最大可用的Pod数 4(2 old pod + 2 new pod)",进入下一轮。
myapp01-64db45b8bd   1         2         2       8m13s
myapp01-855dcbc755   3         2         2       4m12s
myapp01-64db45b8bd   1         2         2       8m13s
myapp01-64db45b8bd   1         1         1       8m13s # <== 滚动更新第三轮：OldReplicaSet: 1(均可用)
myapp01-855dcbc755   3         2         2       4m12s  
myapp01-855dcbc755   3         3         2       4m12s # <== 滚动更新第三轮：NewReplicaSet: 3(2可用,1不可用)
                                                       # <-- 是不是保证了"最少可用的Pod数 3"
myapp01-855dcbc755   3         3         3       6m22s # <-- 是不是保证了"最大可用的Pod数 4(3 old pod + 2 new pod)",进入下一轮。
myapp01-64db45b8bd   0         1         1       10m
myapp01-855dcbc755   4         3         3       6m22s
myapp01-64db45b8bd   0         1         1       10m
myapp01-64db45b8bd   0         0         0       10m   # <== 滚动更新第四轮：OldReplicaSet: 0
myapp01-855dcbc755   4         3         3       6m22s 
myapp01-855dcbc755   4         4         3       6m22s # <== 滚动更新第四轮：NewReplicaSet: 4(3可用,1不可用,已达期望Pod数 4),滚动更新完成
myapp01-855dcbc755   4         4         4       8m23s 

# 列出deploy/myapp01对象相关的rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili get rs
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   0         0         0       30m
myapp01-855dcbc755   4         4         4       21m


# 从deploy/myapp01对象的描述信息中查看Events
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili describe deploy/myapp01  | grep -A 10000 "Events"
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  18m    deployment-controller  Scaled up replica set myapp01-64db45b8bd to 4
  Normal  ScalingReplicaSet  14m    deployment-controller  Scaled down replica set myapp01-64db45b8bd to 3
  Normal  ScalingReplicaSet  14m    deployment-controller  Scaled up replica set myapp01-855dcbc755 to 1

  Normal  ScalingReplicaSet  12m    deployment-controller  Scaled down replica set myapp01-64db45b8bd to 2
  Normal  ScalingReplicaSet  12m    deployment-controller  Scaled up replica set myapp01-855dcbc755 to 2

  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled down replica set myapp01-64db45b8bd to 1
  Normal  ScalingReplicaSet  10m    deployment-controller  Scaled up replica set myapp01-855dcbc755 to 3

  Normal  ScalingReplicaSet  8m12s  deployment-controller  Scaled down replica set myapp01-64db45b8bd to 0
  Normal  ScalingReplicaSet  8m12s  deployment-controller  Scaled up replica set myapp01-855dcbc755 to 4


# 列出deploy/myapp01对象相关的Pod副本
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/03.based-4-4-in-maxSurge-be-0# kubectl -n lili get pods --show-labels | grep myapp01
myapp01-855dcbc755-4wh9s   1/1     Running   0          9m8s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-557qb   1/1     Running   0          15m    app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-pl92n   1/1     Running   0          11m    app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-vqn4s   1/1     Running   0          13m    app=myapp01,pod-template-hash=855dcbc755,version=stable
``

## 清理环境
```
kubectl delete -f .

```
