1.部署应用(01.deploy_myapp01.yaml)
```
## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl apply -f 01.deploy_myapp01.yaml 
deployment.apps/myapp01 created

## 列出deploy/myapp01对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get deploy/myapp01
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
myapp01   1/1     1            1           15s     # 可看出Pod副本数为1,已就绪

## 从deploy/myapp01对象的描述信息中查看NewReplicaSet对应的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-64c4b4659c (1/1 replicas created)

## 列出deploy/myapp01对象的相关rs(默认只会保留10个)
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs | grep myapp01
myapp01-64c4b4659c   1         1         1       119s

## 列出deploy/myapp01对象相关的Pod副本
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get pods | grep myapp01-64c4b4659c
myapp01-64c4b4659c-wnbbh   1/1     Running   0          3m28s

## 查看deploy/myapp01对象的描述信息
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01
Name:                   myapp01
Namespace:              lili
CreationTimestamp:      Mon, 02 Dec 2024 14:27:52 +0800
Labels:                 deploy=myapp01
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=myapp01
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge 
Pod Template:
  Labels:  app=myapp01
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   myapp01-64c4b4659c (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  5m43s  deployment-controller  Scaled up replica set myapp01-64c4b4659c to 1
```



2.在线更改deploy/myapp01对象其Pod副本数（02.deploy_myapp01-change-replicas.yaml）
```
## kubectl工具命令行命令在线更改
kubectl -n lili scale --replicas=<期望的Pod副本数> deploy/myapp01

## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl apply -f 02.deploy_myapp01-change-replicas.yaml 
deployment.apps/myapp01 configured

## 查看deploy/myapp01对象当前NewReplicaSet对应着的rs,及其rs的Pod副本数
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01|grep "NewReplicaSet:"
NewReplicaSet:   myapp01-64c4b4659c (2/2 replicas created)
   # 可看到NewReplicaSet对应的还是之前的rs资源对象,但Pod副本数已是2了

root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs myapp01-64c4b4659c
NAME                 DESIRED   CURRENT   READY   AGE
myapp01-64c4b4659c   2         2         2       13m    

## 可看到期望副本数为2，当前副本数为2，就绪副本数为2
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep "Replicas:"
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
   # 从deploy/myapp01对象的描述信息中查看其当前NewReplicaSet对应rs的Pod副本数

## 列出deploy/myapp01对象相关的pod,并显示labels
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get pods --show-labels | grep myapp01-64c4b4659c
myapp01-64c4b4659c-qdd76   1/1  Running   0   14m   app=myapp01,pod-template-hash=64c4b4659c
myapp01-64c4b4659c-wnbbh   1/1  Running   0   26m   app=myapp01,pod-template-hash=64c4b4659c
```





3.在线更改deploy/myapp01对象其template中Pod的Labels(03.deploy_myapp01-change-labels.yaml)，会触发deploy/myapp01对象的更新。
```
## kubectl工具命令行命令在线更改（交互式界面）
# kubectl -n lili  edit deploy/myapp01

## 检查deploy/myapp01对象是否可以更新,因为可以被暂停
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep Progressing
  Progressing    True    NewReplicaSetAvailable
    # 若出现Progressing    Unknown  DeploymentPaused表示已被暂停

## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl apply -f 03.deploy_myapp01-change-labels.yaml 
deployment.apps/myapp01 configured

## 查看deploy/myapp01对象当前NewReplicaSet对应的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-9fbd79556 (2/2 replicas created)
   # 可看出NewReplicaSet对应的rs资源对象已变了
# 这是新创建出来的,因为之前只有一个,并不是它。

## 列出deploy/myapp01对象相关的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs | grep myapp01
myapp01-64c4b4659c   0     0    0       29m   # OldReplicaSet已被缩至0了。
myapp01-9fbd79556    2     2    2       2m4s  # 已达到期望Pod数,均已就绪。

## 列出deploy/myapp01对象的相关Pod,并显示labels
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get pods --show-labels | grep myapp01-9fbd79556 
myapp01-9fbd79556-rfkbp   1/1     Running   0   3m31s   app=myapp01,pod-template-hash=9fbd79556,version=stable
myapp01-9fbd79556-spr6w   1/1     Running   0   3m29s   app=myapp01,pod-template-hash=9fbd79556,version=stable
```



4.在线更改deploy/myapp01对象其template中Pod的里面某主容器的image(04.deploy_myapp01-change-image-version-up.yaml)，会触发deploy/myapp01对象的更新。
```
## 查看deploy/myapp01对象的描述信息,从中可看到相应主容器及对应的image
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep -B 10000 "Events:"
Name:                   myapp01
Namespace:              lili
CreationTimestamp:      Mon, 02 Dec 2024 14:27:52 +0800
Labels:                 deploy=myapp01
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=myapp01
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=myapp01
           version=stable
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   myapp01-9fbd79556 (2/2 replicas created)
Events:

## kubectl工具命令行命令
# kubectl -n lili set image 主容器名=IMAGE deploy/myapp01

## 应用manifests
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl apply -f 04.deploy_myapp01-change-image-version-up.yaml 
deployment.apps/myapp01 configured

## 查看deploy/myapp01对象其NewReplicaSet对应的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili describe deploy/myapp01 | grep "NewReplicaSet:"
NewReplicaSet:   myapp01-658d67dc6f (2/2 replicas created)
   # 可看出NewReplicaSet对应的rs资源对象已变了

## 查看deploy/myapp01对象其NewReplicaSet的详细信息
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs/myapp01-658d67dc6f -o wide
NAME                 DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                                                SELECTOR
myapp01-658d67dc6f   2         2         2       4m17s   myapp01      swr.cn-north-1.myhuaweicloud.com/library/nginx:1.17   app=myapp01,pod-template-hash=658d67dc6f
    # 可看到所有Pod副本均已就绪
    # 其myapp01容器的image也变了

## 列出deploy/myapp01对象其相关的pods
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get pods 
NAME                       READY   STATUS    RESTARTS   AGE
myapp01-658d67dc6f-ljssc   1/1     Running   0          5m21s
myapp01-658d67dc6f-pmvb4   1/1     Running   0          5m22s

## 列出deploy/myapp01对象其相关的rs资源对象
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs | grep myapp01
myapp01-64c4b4659c   0         0         0       38m
myapp01-658d67dc6f   2         2         2       2m16s
myapp01-9fbd79556    0         0         0       11m
    # 不要相应这里的排序，不要以为回到了第二个版本(rs资源对象)

## 列出deploy/myapp01对象的历史版本
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili rollout history  deploy/myapp01
deployment.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>

## 列出deploy/myapp01对象的历史版本，并显示某REVISION的详细信息
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili rollout history  deploy/myapp01  --revision=1
deployment.apps/myapp01 with revision #1
Pod Template:
  Labels:	app=myapp01
	pod-template-hash=64c4b4659c
  Containers:
   myapp01:
    Image:	swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
   #
   # 可看到其pod-template-hash,这样就可以知道其对应的是哪个rs资源对象了
   # kubectl -n lili get rs |grep 64c4b4659c
   # 也可以看到相应主容器对应的image,你可以作为rollout时的一个参考
   # 
```



5.回滚操作
```
## 需求
当前是用的image是nginx:1.17,我想回滚至nginx:1.16版本的

## 查看deploy/myapp01对象其history（看不出差异）
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili rollout history deploy/myapp01
deployment.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
   #
   # 3是当前的,即其对应的rs资源对象,为deploy资源对象的NewReplicaSet
   # 

## 查看deploy/myapp01对象其history中某REVISION的详细信息
kubectl -n lili rollout history --revision=3 deploy/myapp01

## 执行manifests中所准备的shell脚本,做回滚前的观察
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# bash print-deploy-source-object-all-rs-describe-and-history-revision.sh 

#<=== deploy/myapp01 Object RolloutHistoryVersion=3  RS(NewReplicaSet)= [ myapp01-658d67dc6f ] 
 
==>RolloutHistoryVersion=1 RS=myapp01-64c4b4659c
  Pod Template:
  Labels:  app=myapp01
           pod-template-hash=64c4b4659c
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
   
==>RolloutHistoryVersion=2 RS=myapp01-9fbd79556
  Pod Template:
  Labels:  app=myapp01
           pod-template-hash=9fbd79556
           version=stable
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
   
==>RolloutHistoryVersion=3 RS=myapp01-658d67dc6f
  Pod Template:
  Labels:  app=myapp01
           pod-template-hash=658d67dc6f
           version=stable
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.17
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>


## 我现在想回滚至REVISION为1
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili rollout undo --to-revision=1 deploy/myapp01
deployment.apps/myapp01 rolled back

## 列出deploy/myapp01对象所有的history
root@master01:~/tools/pod-controller/01.deployments/03.strategy-of-RollingUpdate/01.based-4-4-in-default# kubectl -n lili rollout history deploy/myapp01
deployment.apps/myapp01 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>
   #
   # 1变成了4,它是当前的,即其对应的rs资源对象,为deploy资源对象的NewReplicaSet
   # 

root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili rollout history --revision=4 deploy/myapp01 
deployment.apps/myapp01 with revision #4
Pod Template:
  Labels:	app=myapp01
	pod-template-hash=64c4b4659c
  Containers:
   myapp01:
    Image:	swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>

root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get rs | grep myapp01-64c4b4659c
myapp01-64c4b4659c   2         2         2       84m

## 查看deploy/myapp01对象的相关pods
root@master01:~/tools/pod-controller/01.deployments/01.base-understand# kubectl -n lili get pods --show-labels
NAME                       READY   STATUS    RESTARTS   AGE     LABELS
myapp01-64c4b4659c-9b6d7   1/1     Running   0          4m14s   app=myapp01,pod-template-hash=64c4b4659c
myapp01-64c4b4659c-qhqrp   1/1     Running   0          4m12s   app=myapp01,pod-template-hash=64c4b4659c
   # 可看到是没有version=stable标签的了
```



6.清理环境
```
kubectl delete -f .

```

