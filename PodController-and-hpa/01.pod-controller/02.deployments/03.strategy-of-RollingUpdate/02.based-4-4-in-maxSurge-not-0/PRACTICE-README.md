## 1.部署应用(01.deploy_myapp01.yaml)
```
# 应用manifests
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl apply -f 01.deploy_myapp01.yaml
deployment.apps/myapp01 created

# 从deploy/myapp01对象的描述信息中查看NewReplicaSet是哪个rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-64db45b8bd (4/4 replicas created)

# 列出deploy/myapp01对象的所有rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili get rs | grep myapp01
myapp01-64db45b8bd   4         4         0       103s
   #
   # 均未就绪/可用
   # 要等其就绪/可用后,再做后面的操作
   #
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili get rs | grep myapp01
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m30s
   #
   # 均已就绪/可用
   # 可以做后面的操作了
   #

# 查看deploy/myapp01对象相关的Pod
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili get pods --show-labels | grep myapp01
myapp01-64db45b8bd-8ccwh   1/1     Running   0          3m13s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-b4xjk   1/1     Running   0          3m13s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-ftx2s   1/1     Running   0          3m13s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-j4d4x   1/1     Running   0          3m13s   app=myapp01,pod-template-hash=64db45b8bd
```

## 2.触发更新(02.deploy_myapp01-change-labels.yaml)
```
# 另开xshell窗口 watch rs其变化的说明
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m28s
光标在闪烁

# 应用maniefsts
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl apply -f 02.deploy_myapp01-change-labels.yaml
deployment.apps/myapp01 configured

# 从deploy/myapp01对象的描述信息中查看OldReplicaSet及NewReplicaSet
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili describe deploy/myapp01 | grep -E "OldReplicaSets:|NewReplicaSet:"
OldReplicaSets:  myapp01-64db45b8bd (3/3 replicas created)
NewReplicaSet:   myapp01-855dcbc755 (2/2 replicas created)

# 所watch rs其变化的说明
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       9m23s  # <== 滚动更新第一轮：OldReplicaSet未动: 4(均可用)
myapp01-855dcbc755   1         1         0       3s     # <== 滚动更新第一轮: NewReplicaSet扩至：1(均不可用)
                                                        # <-- 是不是保证了"最少可用的Pod数 4"
myapp01-855dcbc755   1         1         1       2m11s  # <-- 是不是保证了"最大可用的Pod数 5(4 old pod + 1 new pod)",进入下一轮。 
myapp01-64db45b8bd   3         4         4       11m    
myapp01-855dcbc755   2         1         1       2m11s
myapp01-64db45b8bd   3         4         4       11m   
myapp01-64db45b8bd   3         3         3       11m    # <== 滚动更新第二轮：OldReplicaSet缩至：3(均可用)
myapp01-855dcbc755   2         1         1       2m11s  
myapp01-855dcbc755   2         2         1       2m11s  # <== 滚动更新第二轮：NewReplicaSet扩至：2(1可用,1不可用)
                                                        # <-- 是不是保证了"最少可用的Pod数 4"
myapp01-855dcbc755   2         2         2       4m21s  # <-- 是不是保证了"最大可用的Pod数 5(3 old pod + 2 new pod)",进入下一轮。 
myapp01-64db45b8bd   2         3         3       13m
myapp01-855dcbc755   3         2         2       4m21s
myapp01-64db45b8bd   2         3         3       13m
myapp01-855dcbc755   3         2         2       4m21s
myapp01-64db45b8bd   2         2         2       13m    # <== 滚动更新第三轮：OldReplicaSet缩至：2(均可用)
myapp01-855dcbc755   3         3         2       4m21s  # <== 滚动更新第三轮：NewReplicaSet缩至：3(2可用,1不可用)
                                                        # <-- 是不是保证了"最少可用的Pod数 4"
myapp01-855dcbc755   3         3         3       6m22s  # <-- 是不是保证了"最大可用的Pod数 5(2 old pod + 3 new pod)",进入下一轮。 
myapp01-64db45b8bd   1         2         2       15m
myapp01-855dcbc755   4         3         3       6m22s
myapp01-64db45b8bd   1         2         2       15m
myapp01-855dcbc755   4         3         3       6m22s
myapp01-64db45b8bd   1         1         1       15m    # <== 滚动更新第四轮：OldReplicaSet缩至：1(均可用)
myapp01-855dcbc755   4         4         3       6m22s  # <== 滚动更新第四轮：NewReplicaSet扩至：4(3可用,1不可用,已达期望Pod数 4)
                                                        # <-- 是不是保证了"最少可用的Pod数 4"
myapp01-855dcbc755   4         4         4       8m32s  # <-- 是不是保证了"最大可用的Pod数 5(1 old pod + 4 new pod)"
myapp01-64db45b8bd   0         1         1       17m    
myapp01-64db45b8bd   0         1         1       17m
myapp01-64db45b8bd   0         0         0       17m    # <-- 是不是保证了"最少可用的Pod数 4",才将OldReplicaSet缩放至0的

# 列出deploy/myapp01对象相关的rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili get rs
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   0         0         0       30m
myapp01-855dcbc755   4         4         4       21m

# 从deploy/myapp01对象的描述信息中查看Events
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili describe deploy/myapp01  | grep -A 10000 "Events"
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  31m   deployment-controller  Scaled up replica set myapp01-64db45b8bd to 4
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 1

  Normal  ScalingReplicaSet  19m   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 3
  Normal  ScalingReplicaSet  19m   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 2

  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 2
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 3

  Normal  ScalingReplicaSet  15m   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 1
  Normal  ScalingReplicaSet  15m   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 4
  Normal  ScalingReplicaSet  13m   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 0

# 列出deploy/myapp01对象相关的Pod副本
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/02.based-4-4-in-maxSurge-not-0# kubectl -n lili get pods --show-labels | grep myapp01
myapp01-855dcbc755-67p78   1/1     Running   0          4m19s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-kbrvb   1/1     Running   0          2m18s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-nknl2   1/1     Running   0          8m40s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-phjpm   1/1     Running   0          6m29s   app=myapp01,pod-template-hash=855dcbc755,version=stable
```

## 3.清理环境
```
kubectl delete -f .

```
