## 1.部署应用(01.deploy_myapp01.yaml)
```
# 应用manifests
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl apply -f 01.deploy_myapp01.yaml 
deployment.apps/myapp01 created

# 从deploy/myapp01对象的描述信息中查看NewReplicaSet是哪个rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-64db45b8bd (4/4 replicas created)

# 列出deploy/myapp01对象的所有rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili get rs | grep myapp01
myapp01-64db45b8bd   4         4         0       103s
   # 
   # 均未就绪/可用
   # 要等其就绪/可用后,再做后面的操作
   # 
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili get rs | grep myapp01
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m30s
   #
   # 均已就绪/可用
   # 可以做后面的操作了
   #

# 查看deploy/myapp01对象相关的Pod
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili get pods --show-labels | grep myapp01
NAME                       READY   STATUS    RESTARTS   AGE     LABELS
myapp01-64db45b8bd-529c5   1/1     Running   0          3m34s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-nrqhj   1/1     Running   0          3m34s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-skcq7   1/1     Running   0          3m34s   app=myapp01,pod-template-hash=64db45b8bd
myapp01-64db45b8bd-xbxhs   1/1     Running   0          3m34s   app=myapp01,pod-template-hash=64db45b8bd
```


## 2.触发更新(02.deploy_myapp01-change-labels.yaml)
```
# 另开xshell窗口,watch rs其变化的说明
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m28s
光标在闪烁

# 应用manifests
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl apply -f 02.deploy_myapp01-change-labels.yaml
deployment.apps/myapp01 configured

# 从deploy/myapp01对象的描述信息中查看OldReplicaSet及NewReplicaSet
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili describe deploy/myapp01 | grep -E "OldReplicaSets:|NewReplicaSet:"
OldReplicaSets:  myapp01-64db45b8bd (3/3 replicas created)
NewReplicaSet:   myapp01-855dcbc755 (2/2 replicas created)

# 从watch rs的结果中来分析
root@master01:~# kubectl -n lili get rs --watch
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   4         4         4       2m28s
myapp01-855dcbc755   1         0         0       0s
myapp01-855dcbc755   1         0         0       0s
myapp01-64db45b8bd   3         4         4       2m50s
myapp01-855dcbc755   1         1         0       0s
myapp01-855dcbc755   2         1         0       1s
myapp01-64db45b8bd   3         4         4       2m51s
myapp01-64db45b8bd   3         3         3       2m51s   # <== 滚动更新第一轮：OldReplicaSet缩至：3(均可用)
myapp01-855dcbc755   2         1         0       1s
myapp01-855dcbc755   2         2         0       1s      # <== 滚动更新第一轮：NewReplicaSet扩至: 2(均不可用)
                                                         # <-- 是不是保证了"最少可用的Pod数 3"
myapp01-855dcbc755   2         2         1       2m1s    # <-- 是不是保证了"最大可用的Pod数 4(3 old pod + 1 new pod)",进入下一轮。 
myapp01-64db45b8bd   2         3         3       4m51s
myapp01-855dcbc755   3         2         1       2m1s
myapp01-64db45b8bd   2         3         3       4m51s
myapp01-855dcbc755   3         2         1       2m1s
myapp01-64db45b8bd   2         2         2       4m51s   # <== 滚动更新第二轮：OldReplicaSet缩至：2(均可用)
myapp01-855dcbc755   3         3         1       2m1s    # <== 滚动更新第二轮：NewReplicaSet扩至: 3(1可用,2不可用)
                                                         # <-- 是不是保证了"最少可用的Pod数 3"
myapp01-855dcbc755   3         3         2       2m11s   # <-- 是不是保证了"最大可用的Pod数 4(2 old pod + 2 new pod)",进入下一轮。 
myapp01-64db45b8bd   1         2         2       5m1s
myapp01-64db45b8bd   1         2         2       5m1s
myapp01-855dcbc755   4         3         2       2m11s
myapp01-855dcbc755   4         3         2       2m11s
myapp01-64db45b8bd   1         1         1       5m1s    # <== 滚动更新第三轮：OldReplicaSet缩至：1(均可用)
myapp01-855dcbc755   4         4         2       2m11s   # <== 滚动更新第三轮：NewReplicaSet扩至：4(2可用,2不可用,已达期望Pod数)
                                                         # <-- 是不是保证了"最少可用的Pod数 3"
myapp01-855dcbc755   4         4         3       4m11s   # <-- 是不是保证了"最大可用的Pod数 4(1 old pod + 3 new pod)"
myapp01-64db45b8bd   0         1         1       7m1s    # <-- 是不是保证了"最少可用的Pod数 3"后,才将OldReplicaSet缩放至0的。
myapp01-64db45b8bd   0         1         1       7m1s    
myapp01-64db45b8bd   0         0         0       7m2s

# 列出deploy/myapp01对象相关的rs
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili get rs
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64db45b8bd   0         0         0       30m
myapp01-855dcbc755   4         4         4       21m

# 从deploy/myapp01对象的描述信息中查看Events
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili describe deploy/myapp01 | grep -A 10000 "Events:"
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  9m31s  deployment-controller  Scaled up replica set myapp01-64db45b8bd to 4
  Normal  ScalingReplicaSet  5m4s   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 1
  Normal  ScalingReplicaSet  5m4s   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 3
  Normal  ScalingReplicaSet  5m4s   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 2

  Normal  ScalingReplicaSet  3m3s   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 2
  Normal  ScalingReplicaSet  3m3s   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 3

  Normal  ScalingReplicaSet  3m3s   deployment-controller  Scaled down replica set myapp01-64db45b8bd to 1
  Normal  ScalingReplicaSet  3m3s   deployment-controller  Scaled up replica set myapp01-855dcbc755 to 4
  Normal  ScalingReplicaSet  53s    deployment-controller  Scaled down replica set myapp01-64db45b8bd to 0

# 列出deploy/myapp01对象相关的Pod副本
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili get pods --show-labels | grep myapp01
myapp01-855dcbc755-8vmns   1/1     Running   0          6m32s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-bjkk4   1/1     Running   0          4m31s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-dmjcb   1/1     Running   0          6m32s   app=myapp01,pod-template-hash=855dcbc755,version=stable
myapp01-855dcbc755-nksjb   1/1     Running   0          4m31s   app=myapp01,pod-template-hash=855dcbc755,version=stable
```

## 3.清理环境
```
kubectl delete -f .

```
